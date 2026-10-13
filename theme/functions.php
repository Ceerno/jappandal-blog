<?php
/**
 * Jappandal — fonctions du thème.
 *
 * @package Jappandal
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

define( 'JAPPANDAL_FONTS_URL', 'https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,400;12..96,600;12..96,700;12..96,800&family=Source+Serif+4:ital,opsz,wght@0,8..60,400;0,8..60,600;1,8..60,400&family=JetBrains+Mono:wght@500&display=swap' );

/**
 * Supports du thème.
 */
function jappandal_setup() {
	add_theme_support( 'wp-block-styles' );
	add_theme_support( 'editor-styles' );
	add_editor_style( array( 'style.css', JAPPANDAL_FONTS_URL ) );
	load_theme_textdomain( 'jappandal', get_template_directory() . '/languages' );
}
add_action( 'after_setup_theme', 'jappandal_setup' );

/**
 * Polices + feuille de style.
 */
function jappandal_assets() {
	wp_enqueue_style( 'jappandal-fonts', JAPPANDAL_FONTS_URL, array(), null );
	wp_enqueue_style( 'jappandal-style', get_stylesheet_uri(), array(), wp_get_theme()->get( 'Version' ) );
}
add_action( 'wp_enqueue_scripts', 'jappandal_assets' );

/**
 * Preconnect Google Fonts.
 */
function jappandal_resource_hints( $urls, $relation_type ) {
	if ( 'preconnect' === $relation_type ) {
		$urls[] = array( 'href' => 'https://fonts.gstatic.com', 'crossorigin' );
	}
	return $urls;
}
add_filter( 'wp_resource_hints', 'jappandal_resource_hints', 10, 2 );

/**
 * Favicon : icônes du thème tant qu'aucune « Icône du site » n'est choisie dans
 * Réglages › Général. Passer par ce filtre couvre aussi /favicon.ico et l'admin.
 */
function jappandal_site_icon_url( $url, $size ) {
	if ( get_option( 'site_icon' ) ) {
		return $url;
	}
	if ( $size <= 32 ) {
		$file = 'icon-32.png';
	} elseif ( 180 === (int) $size ) {
		$file = 'apple-touch-icon.png';
	} elseif ( $size <= 192 ) {
		$file = 'icon-192.png';
	} else {
		$file = 'icon-512.png';
	}
	return get_theme_file_uri( 'assets/favicon/' . $file );
}
add_filter( 'get_site_icon_url', 'jappandal_site_icon_url', 10, 2 );

/**
 * Favicon vectoriel + manifeste (en complément des balises de wp_site_icon()).
 */
function jappandal_favicon_links() {
	if ( get_option( 'site_icon' ) ) {
		return;
	}
	printf( '<link rel="icon" href="%s" type="image/svg+xml" />' . "\n", esc_url( get_theme_file_uri( 'assets/favicon/favicon.svg' ) ) );
	printf( '<link rel="manifest" href="%s" />' . "\n", esc_url( get_theme_file_uri( 'assets/favicon/site.webmanifest' ) ) );
	echo '<meta name="theme-color" content="#00564B" />' . "\n";
}
add_action( 'wp_head', 'jappandal_favicon_links', 98 );

/**
 * Catégorie de compositions.
 */
function jappandal_pattern_categories() {
	register_block_pattern_category( 'jappandal', array( 'label' => __( 'Jappandal', 'jappandal' ) ) );
}
add_action( 'init', 'jappandal_pattern_categories' );

/**
 * Temps de lecture estimé — shortcode [temps_lecture].
 */
function jappandal_reading_time() {
	// str_word_count() coupe les mots accentués : on compte les blocs séparés par des espaces.
	$text  = wp_strip_all_tags( strip_shortcodes( get_post_field( 'post_content', get_the_ID() ) ) );
	$words = count( preg_split( '/\s+/u', $text, -1, PREG_SPLIT_NO_EMPTY ) );
	$min   = max( 1, (int) ceil( $words / 220 ) );
	/* translators: %d: minutes */
	return esc_html( sprintf( _n( '%d min de lecture', '%d min de lecture', $min, 'jappandal' ), $min ) );
}
add_shortcode( 'temps_lecture', 'jappandal_reading_time' );

/**
 * « À lire ensuite » (single.html, queryId 20) : ne pas reproposer l'article en cours.
 */
function jappandal_related_exclude_current( $query, $block ) {
	if ( is_singular( 'post' ) && isset( $block->context['queryId'] ) && 20 === (int) $block->context['queryId'] ) {
		$query['post__not_in'] = array_merge( (array) ( $query['post__not_in'] ?? array() ), array( get_queried_object_id() ) );
	}
	return $query;
}
add_filter( 'query_loop_block_query_vars', 'jappandal_related_exclude_current', 10, 2 );

/**
 * Menu de l'en-tête : WordPress ne marque pas la page courante sur les liens
 * personnalisés. On compare le chemin du lien à celui de la page affichée ;
 * « Articles » (/blog/) reste actif sur un article, une rubrique ou une étiquette.
 */
function jappandal_nav_current( $html, $block ) {
	$url = $block['attrs']['url'] ?? '';
	if ( '' === $url || '/' !== $url[0] ) {
		return $html;
	}
	$link    = trailingslashit( $url );
	$current = trailingslashit( wp_parse_url( add_query_arg( array() ), PHP_URL_PATH ) ?: '/' );
	$active  = $link === $current || ( '/blog/' === $link && ( is_home() || is_singular( 'post' ) || is_category() || is_tag() ) );
	if ( ! $active ) {
		return $html;
	}
	$html = preg_replace( '/(<li[^>]*class=")/', '$1current-menu-item ', $html, 1 );
	return preg_replace( '/<a /', '<a aria-current="page" ', $html, 1 );
}
add_filter( 'render_block_core/navigation-link', 'jappandal_nav_current', 10, 2 );

/**
 * Formulaire MailPoet du bloc newsletter : le premier formulaire actif.
 * Forcer un autre formulaire : add_filter( 'jappandal_mailpoet_form_id', fn() => 3 );
 * Renvoie 0 si MailPoet est inactif ou sans formulaire (le bloc n'affiche alors que le texte).
 */
function jappandal_mailpoet_form_id() {
	static $id = null;
	if ( null !== $id ) {
		return $id;
	}
	$id = 0;
	if ( ! defined( 'MAILPOET_VERSION' ) ) {
		return $id;
	}
	$id = (int) apply_filters( 'jappandal_mailpoet_form_id', 0 );
	if ( ! $id ) {
		global $wpdb;
		$table    = $wpdb->prefix . 'mailpoet_forms';
		$suppress = $wpdb->suppress_errors( true );
		$id       = (int) $wpdb->get_var( "SELECT id FROM {$table} WHERE status = 'enabled' AND deleted_at IS NULL ORDER BY id ASC LIMIT 1" ); // phpcs:ignore WordPress.DB.PreparedSQL.InterpolatedNotPrepared
		$wpdb->suppress_errors( $suppress );
	}
	return $id;
}

/**
 * Longueur des extraits.
 */
add_filter( 'excerpt_length', function () { return 26; } );
