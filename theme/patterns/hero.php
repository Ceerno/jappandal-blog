<?php
/**
 * Title: Accueil — Hero
 * Slug: jappandal/hero
 * Categories: jappandal, banner
 * Description: Titre d'accueil + dernier article mis en avant.
 */
?>
<!-- wp:group {"align":"full","style":{"spacing":{"padding":{"top":"var:preset|spacing|60","bottom":"var:preset|spacing|50"}}},"layout":{"type":"constrained"}} -->
<div class="wp-block-group alignfull" style="padding-top:var(--wp--preset--spacing--60);padding-bottom:var(--wp--preset--spacing--50)">
<!-- wp:columns {"verticalAlignment":"center","align":"wide","style":{"spacing":{"blockGap":{"left":"3.5rem"}}}} -->
<div class="wp-block-columns alignwide are-vertically-aligned-center">
<!-- wp:column {"verticalAlignment":"center","width":"58%"} -->
<div class="wp-block-column is-vertically-aligned-center" style="flex-basis:58%">
<!-- wp:paragraph {"className":"jp-kicker"} -->
<p class="jp-kicker"><?php esc_html_e( 'Le carnet de Thierno LO · Dakar', 'jappandal' ); ?></p>
<!-- /wp:paragraph -->
<!-- wp:heading {"level":1} -->
<h1 class="wp-block-heading">Construire le numérique d'ici, <span style="color:#00564B" class="has-inline-color">dans nos langues.</span></h1>
<!-- /wp:heading -->
<!-- wp:paragraph {"textColor":"gris","style":{"typography":{"fontSize":"1.3rem","lineHeight":"1.6"}}} -->
<p class="has-gris-color has-text-color" style="font-size:1.3rem;line-height:1.6">Expertise produit, projets en cours et réflexions sur la tech au Sénégal — de l'idée au code, du wolof au cloud.</p>
<!-- /wp:paragraph -->
<!-- wp:buttons -->
<div class="wp-block-buttons"><!-- wp:button -->
<div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="#articles">Lire les derniers articles</a></div>
<!-- /wp:button --><!-- wp:button {"className":"is-style-outline","textColor":"encre"} -->
<div class="wp-block-button is-style-outline"><a class="wp-block-button__link has-encre-color has-text-color wp-element-button" href="/projets/">Voir les projets</a></div>
<!-- /wp:button --></div>
<!-- /wp:buttons -->
</div>
<!-- /wp:column -->
<!-- wp:column {"verticalAlignment":"center","width":"42%"} -->
<div class="wp-block-column is-vertically-aligned-center" style="flex-basis:42%">
<!-- wp:query {"queryId":1,"query":{"perPage":1,"pages":0,"offset":0,"postType":"post","order":"desc","orderBy":"date","sticky":"","inherit":false}} -->
<div class="wp-block-query"><!-- wp:post-template -->
<!-- wp:group {"backgroundColor":"encre","textColor":"papier","style":{"border":{"radius":"24px"},"spacing":{"padding":{"bottom":"1.75rem"},"blockGap":"0"}},"className":"jp-dark","layout":{"type":"constrained"}} -->
<div class="wp-block-group jp-dark has-papier-color has-encre-background-color has-text-color has-background" style="border-radius:24px;padding-bottom:1.75rem">
<!-- wp:post-featured-image {"isLink":true,"aspectRatio":"16/10","style":{"border":{"radius":{"topLeft":"24px","topRight":"24px"}}}} /-->
<!-- wp:group {"style":{"spacing":{"padding":{"top":"1.5rem","left":"1.75rem","right":"1.75rem"},"blockGap":"0.75rem"}},"layout":{"type":"flex","orientation":"vertical"}} -->
<div class="wp-block-group" style="padding-top:1.5rem;padding-right:1.75rem;padding-left:1.75rem">
<!-- wp:post-terms {"term":"category","style":{"typography":{"textTransform":"uppercase","letterSpacing":"0.08em","fontSize":"0.75rem"},"elements":{"link":{"color":{"text":"var:preset|color|ocre-clair"}}}},"fontFamily":"mono","prefix":"À la une · "} /-->
<!-- wp:post-title {"isLink":true,"style":{"typography":{"fontSize":"1.75rem","lineHeight":"1.15"},"elements":{"link":{"color":{"text":"var:preset|color|papier"}}}}} /-->
<!-- wp:post-excerpt {"excerptLength":20,"style":{"color":{"text":"#C9D3D0"}}} /-->
</div>
<!-- /wp:group -->
</div>
<!-- /wp:group -->
<!-- /wp:post-template --></div>
<!-- /wp:query -->
</div>
<!-- /wp:column -->
</div>
<!-- /wp:columns -->
</div>
<!-- /wp:group -->
