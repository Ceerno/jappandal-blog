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
	$words = str_word_count( wp_strip_all_tags( get_post_field( 'post_content', get_the_ID() ) ) );
	$min   = max( 1, (int) ceil( $words / 220 ) );
	/* translators: %d: minutes */
	return esc_html( sprintf( _n( '%d min de lecture', '%d min de lecture', $min, 'jappandal' ), $min ) );
}
add_shortcode( 'temps_lecture', 'jappandal_reading_time' );

/**
 * Longueur des extraits.
 */
add_filter( 'excerpt_length', function () { return 26; } );
