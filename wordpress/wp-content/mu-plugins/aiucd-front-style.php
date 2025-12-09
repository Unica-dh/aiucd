<?php
/**
 * Plugin Name: AIUCD Front Style
 * Description: Imposta la larghezza del contenuto e riduce lo spazio tra header e contenuto per la front page.
 * Version: 1.0
 * Author: AI assistant
 */

if ( ! defined( 'WPINC' ) ) {
    die;
}

add_action('wp_enqueue_scripts', 'aiucd_front_style_css');
function aiucd_front_style_css() {
    // Applica la regola quando siamo nella front page o nella pagina con lo slug specificato
    if ( is_front_page() || is_page('xv-convegno-annuale-dellassociazione-per-linformatica-umanistica-e-la-cultura-digitale-aiucd') ) {
        $css = ":root{ --wp--style--global--content-size:1020px !important; }
.wp-block-group.has-global-padding.is-layout-constrained{ max-width: var(--wp--style--global--content-size) !important; margin-left:auto !important; margin-right:auto !important; }
header, .site-header{ margin-bottom:8px !important; padding-bottom:0 !important; }
main, .site-main{ margin-top:8px !important; padding-top:0 !important; }
";
        wp_register_style('aiucd-front-style', false);
        wp_enqueue_style('aiucd-front-style');
        wp_add_inline_style('aiucd-front-style', $css);
    }
}
