<?php
/**
 * Plugin Name: Polylang Menu Setup
 * Description: Shortcode per mostrare menu in base alla lingua corrente
 * Version: 4.0
 */

if ( ! defined( 'WPINC' ) ) {
    die;
}

/**
 * Test shortcode per verificare che il plugin sia caricato
 */
add_shortcode( 'test_menu', function() {
    return 'TEST SHORTCODE WORKS';
} );

/**
 * Shortcode: [language_menu]
 * Mostra il menu corretto per la lingua corrente
 */
add_shortcode( 'language_menu', function( $atts ) {
    // Verifica se Polylang è attivo
    if ( ! function_exists( 'pll_current_language' ) ) {
        return '<p style="color:red;">Polylang non trovato</p>';
    }

    $current_lang = pll_current_language();
    
    if ( empty( $current_lang ) ) {
        return '<p style="color:red;">Lingua corrente non riconosciuta</p>';
    }

    $menu_id = ( $current_lang === 'en' ) ? 37 : 25;

    // Mostra il menu
    ob_start();
    wp_nav_menu( array(
        'menu'        => $menu_id,
        'fallback_cb' => function() { return '<p>Menu vuoto</p>'; },
        'echo'        => true,
    ) );
    return ob_get_clean();
} );

