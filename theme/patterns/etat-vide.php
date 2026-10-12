<?php
/**
 * Title: État vide (aucun article)
 * Slug: jappandal/etat-vide
 * Categories: jappandal
 * Inserter: no
 * Description: Affiché quand une liste d'articles est vide : propose une suite au lecteur.
 */
?>
<!-- wp:group {"style":{"border":{"radius":"24px"},"spacing":{"padding":{"top":"clamp(2rem, 5vw, 3rem)","bottom":"clamp(2rem, 5vw, 3rem)","left":"clamp(1.5rem, 5vw, 3rem)","right":"clamp(1.5rem, 5vw, 3rem)"},"blockGap":"1rem"}},"backgroundColor":"sable","layout":{"type":"constrained","contentSize":"640px","justifyContent":"left"}} -->
<div class="wp-block-group has-sable-background-color has-background" style="border-radius:24px;padding-top:clamp(2rem, 5vw, 3rem);padding-right:clamp(1.5rem, 5vw, 3rem);padding-bottom:clamp(2rem, 5vw, 3rem);padding-left:clamp(1.5rem, 5vw, 3rem)">
<!-- wp:paragraph {"className":"jp-kicker"} -->
<p class="jp-kicker"><?php esc_html_e( 'Bientôt ici', 'jappandal' ); ?></p>
<!-- /wp:paragraph -->
<!-- wp:heading {"level":2,"fontSize":"large"} -->
<h2 class="wp-block-heading has-large-font-size"><?php esc_html_e( 'Les premiers articles sont en cours d\'écriture.', 'jappandal' ); ?></h2>
<!-- /wp:heading -->
<!-- wp:paragraph {"textColor":"gris","fontSize":"small"} -->
<p class="has-gris-color has-text-color has-small-font-size"><?php esc_html_e( 'En attendant, découvrez les applications Jappandal ou abonnez-vous pour être prévenu de la prochaine publication.', 'jappandal' ); ?></p>
<!-- /wp:paragraph -->
<!-- wp:buttons -->
<div class="wp-block-buttons"><!-- wp:button -->
<div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="/projets/"><?php esc_html_e( 'Voir les projets', 'jappandal' ); ?></a></div>
<!-- /wp:button --><!-- wp:button {"className":"is-style-outline","textColor":"encre"} -->
<div class="wp-block-button is-style-outline"><a class="wp-block-button__link has-encre-color has-text-color wp-element-button" href="#newsletter"><?php esc_html_e( 'S\'abonner', 'jappandal' ); ?></a></div>
<!-- /wp:button --></div>
<!-- /wp:buttons -->
</div>
<!-- /wp:group -->
