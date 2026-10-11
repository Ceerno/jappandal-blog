<?php
/**
 * Title: Grille d'articles
 * Slug: jappandal/derniers-articles
 * Categories: jappandal, query
 * Description: Grille 3 colonnes des derniers articles.
 */
?>
<!-- wp:group {"anchor":"articles","align":"full","style":{"spacing":{"padding":{"top":"var:preset|spacing|60","bottom":"var:preset|spacing|60"},"blockGap":"2.5rem"}},"layout":{"type":"constrained"}} -->
<div id="articles" class="wp-block-group alignfull" style="padding-top:var(--wp--preset--spacing--60);padding-bottom:var(--wp--preset--spacing--60)">
<!-- wp:group {"align":"wide","layout":{"type":"flex","flexWrap":"wrap","justifyContent":"space-between","verticalAlignment":"bottom"}} -->
<div class="wp-block-group alignwide"><!-- wp:heading -->
<h2 class="wp-block-heading">Derniers articles</h2>
<!-- /wp:heading --><!-- wp:paragraph {"fontFamily":"display","style":{"typography":{"fontWeight":"600"}}} -->
<p class="has-display-font-family" style="font-weight:600"><a href="/blog/">Tous les articles →</a></p>
<!-- /wp:paragraph --></div>
<!-- /wp:group -->
<!-- wp:query {"queryId":2,"query":{"perPage":6,"pages":0,"offset":1,"postType":"post","order":"desc","orderBy":"date","inherit":false},"align":"wide"} -->
<div class="wp-block-query alignwide"><!-- wp:post-template {"layout":{"type":"grid","columnCount":3,"minimumColumnWidth":"18rem"},"style":{"spacing":{"blockGap":"2rem"}}} -->
<!-- wp:post-featured-image {"isLink":true,"aspectRatio":"16/10","className":"jp-card-media"} /-->
<!-- wp:post-terms {"term":"category","fontFamily":"mono","style":{"typography":{"textTransform":"uppercase","letterSpacing":"0.08em","fontSize":"0.75rem"},"elements":{"link":{"color":{"text":"var:preset|color|ocre"}}}}} /-->
<!-- wp:post-title {"isLink":true,"level":3,"style":{"typography":{"lineHeight":"1.2"}}} /-->
<!-- wp:post-excerpt /-->
<!-- /wp:post-template -->
<!-- wp:query-no-results -->
<!-- wp:paragraph -->
<p>Les premiers articles arrivent bientôt.</p>
<!-- /wp:paragraph -->
<!-- /wp:query-no-results --></div>
<!-- /wp:query -->
</div>
<!-- /wp:group -->
