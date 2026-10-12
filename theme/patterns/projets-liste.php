<?php
/**
 * Title: Projets Jappandal (fiches détaillées)
 * Slug: jappandal/projets-liste
 * Categories: jappandal
 * Description: Une fiche par application : logo, accroche, description, points forts et lien.
 */

$jappandal_projets = array(
	array(
		'slug'    => 'alhafiz',
		'logo'    => 'alhafiz.png',
		'nom'     => 'Al hafiz',
		'accroche'=> __( 'Moteur de recherche du Saint Coran', 'jappandal' ),
		'texte'   => __( 'Lisez et cherchez dans les 114 sourates du Coran en arabe, en français, en anglais et en wolof. L\'application s\'installe sur le téléphone et fonctionne hors ligne après la première visite.', 'jappandal' ),
		'points'  => array( __( 'Arabe · Français · Anglais · Wolof', 'jappandal' ), __( 'Hors ligne', 'jappandal' ), __( 'Installable', 'jappandal' ) ),
		'url'     => 'https://alhafiz.jappandal.org',
	),
	array(
		'slug'    => 'jangyi',
		'logo'    => 'jangyi.svg',
		'nom'     => 'Jàng Yi',
		'accroche'=> __( 'Pistes des foyers religieux sénégalais', 'jappandal' ),
		'texte'   => __( 'Khassaïdes, chants religieux et causeries de la Tidianiya, de la Mouridiyya, de la Layène et de la Qadiriyya : plus de 1 100 pistes classées par foyer, par auteur et par catégorie, à écouter en streaming ou à télécharger.', 'jappandal' ),
		'points'  => array( __( 'Streaming et hors ligne', 'jappandal' ), __( 'Recherche wolof et arabe', 'jappandal' ), __( 'Favoris', 'jappandal' ) ),
		'url'     => 'https://jangyi.jappandal.org',
	),
	array(
		'slug'    => 'nulaygis',
		'logo'    => 'nulaygis.svg',
		'nom'     => 'Ñu Lay Gis',
		'accroche'=> __( 'Voyez qui vous suit sur chaque site', 'jappandal' ),
		'texte'   => __( 'Une extension de navigateur qui révèle en direct quelles sociétés vous pistent sur les sites que vous visitez. Tout se passe sur votre appareil : rien n\'est collecté, rien n\'est transmis.', 'jappandal' ),
		'points'  => array( __( 'Extension de navigateur', 'jappandal' ), __( '100 % local', 'jappandal' ), __( 'Vie privée', 'jappandal' ) ),
		'url'     => 'https://nulaygis.jappandal.org',
	),
	array(
		'slug'    => 'kurustijaan',
		'logo'    => 'kurustijaan.svg',
		'nom'     => 'Kurus Tijaan',
		'accroche'=> __( 'Chapelet numérique', 'jappandal' ),
		'texte'   => __( 'Un chapelet numérique pour la récitation du wird, avec un compteur et des objectifs à suivre au quotidien.', 'jappandal' ),
		'points'  => array( __( 'Compteur', 'jappandal' ), __( 'Objectifs', 'jappandal' ) ),
		'url'     => '',
	),
);
?>
<!-- wp:group {"align":"wide","className":"jp-showcases","layout":{"type":"grid","minimumColumnWidth":"26rem"},"style":{"spacing":{"blockGap":"1.5rem"}}} -->
<div class="wp-block-group alignwide jp-showcases">
<?php foreach ( $jappandal_projets as $p ) : ?>
<!-- wp:group {"className":"jp-showcase jp-showcase--<?php echo esc_attr( $p['slug'] ); ?>","layout":{"type":"flex","orientation":"vertical","justifyContent":"stretch"},"style":{"spacing":{"blockGap":"0"}}} -->
<div class="wp-block-group jp-showcase jp-showcase--<?php echo esc_attr( $p['slug'] ); ?>">
<!-- wp:group {"className":"jp-showcase-head","layout":{"type":"flex","flexWrap":"nowrap","justifyContent":"space-between","verticalAlignment":"top"}} -->
<div class="wp-block-group jp-showcase-head">
<!-- wp:image {"width":"72px","height":"72px","sizeSlug":"full","linkDestination":"none","className":"jp-showcase-logo"} -->
<figure class="wp-block-image size-full is-resized jp-showcase-logo"><img src="<?php echo esc_url( get_theme_file_uri( 'assets/logos/' . $p['logo'] ) ); ?>" alt="" width="72" height="72" style="width:72px;height:72px"/></figure>
<!-- /wp:image -->
<!-- wp:paragraph {"className":"jp-status <?php echo $p['url'] ? 'is-live' : 'is-soon'; ?>"} -->
<p class="jp-status <?php echo $p['url'] ? 'is-live' : 'is-soon'; ?>"><?php echo $p['url'] ? esc_html__( 'En ligne', 'jappandal' ) : esc_html__( 'Bientôt', 'jappandal' ); ?></p>
<!-- /wp:paragraph -->
</div>
<!-- /wp:group -->
<!-- wp:group {"className":"jp-showcase-body","layout":{"type":"flex","orientation":"vertical"},"style":{"spacing":{"blockGap":"0.75rem"}}} -->
<div class="wp-block-group jp-showcase-body">
<!-- wp:paragraph {"className":"jp-showcase-tagline"} -->
<p class="jp-showcase-tagline"><?php echo esc_html( $p['accroche'] ); ?></p>
<!-- /wp:paragraph -->
<!-- wp:heading {"className":"jp-showcase-title"} -->
<h2 class="wp-block-heading jp-showcase-title"><?php echo esc_html( $p['nom'] ); ?></h2>
<!-- /wp:heading -->
<!-- wp:paragraph {"textColor":"gris"} -->
<p class="has-gris-color has-text-color"><?php echo esc_html( $p['texte'] ); ?></p>
<!-- /wp:paragraph -->
<!-- wp:list {"className":"jp-tags"} -->
<ul class="wp-block-list jp-tags"><?php foreach ( $p['points'] as $point ) : ?><!-- wp:list-item -->
<li><?php echo esc_html( $point ); ?></li>
<!-- /wp:list-item --><?php endforeach; ?></ul>
<!-- /wp:list -->
</div>
<!-- /wp:group -->
<!-- wp:group {"className":"jp-showcase-foot","layout":{"type":"flex","flexWrap":"wrap","justifyContent":"space-between","verticalAlignment":"center"}} -->
<div class="wp-block-group jp-showcase-foot">
<?php if ( $p['url'] ) : ?>
<!-- wp:buttons -->
<div class="wp-block-buttons"><!-- wp:button -->
<div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="<?php echo esc_url( $p['url'] ); ?>"><?php
	/* translators: %s: nom de l'application */
	echo esc_html( sprintf( __( 'Ouvrir %s', 'jappandal' ), $p['nom'] ) );
?> <span aria-hidden="true">↗</span></a></div>
<!-- /wp:button --></div>
<!-- /wp:buttons -->
<!-- wp:paragraph {"className":"jp-showcase-domain"} -->
<p class="jp-showcase-domain"><?php echo esc_html( wp_parse_url( $p['url'], PHP_URL_HOST ) ); ?></p>
<!-- /wp:paragraph -->
<?php else : ?>
<!-- wp:paragraph {"className":"jp-showcase-domain"} -->
<p class="jp-showcase-domain"><?php esc_html_e( 'En cours de développement', 'jappandal' ); ?></p>
<!-- /wp:paragraph -->
<?php endif; ?>
</div>
<!-- /wp:group -->
</div>
<!-- /wp:group -->
<?php endforeach; ?>
</div>
<!-- /wp:group -->
