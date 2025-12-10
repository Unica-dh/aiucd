<?php
/**
 * AIUCD Theme child functions
 */

if ( ! function_exists( 'aiucd_child_enqueue_parent_style' ) ) {
    function aiucd_child_enqueue_parent_style() {
        // Enqueue parent style first
        wp_enqueue_style( 'twentytwentyfour-parent-style', get_template_directory_uri() . '/style.css' );
        // Enqueue child theme stylesheet, dependent on the parent so it loads after
        wp_enqueue_style( 'aiucd-child-style', get_stylesheet_directory_uri() . '/style.css', array( 'twentytwentyfour-parent-style' ), wp_get_theme( get_stylesheet() )->get( 'Version' ) );
    }
}
add_action( 'wp_enqueue_scripts', 'aiucd_child_enqueue_parent_style' );

if ( ! function_exists( 'aiucd_child_block_styles' ) ) :
    function aiucd_child_block_styles() {
        $feature_symbol = get_stylesheet_directory_uri() . '/assets/images/feature-symbol.svg';

        $asterisk_style = "
            .is-style-asterisk:before {
                content: '';
                width: 3rem;
                height: 3rem;
                display: block;
                background-image: url('" . esc_url( $feature_symbol ) . "');
                background-size: contain;
                background-repeat: no-repeat;
            }

            .is-style-asterisk:empty:before { content: none; }
            .is-style-asterisk:-moz-only-whitespace:before { content: none; }
            .is-style-asterisk.has-text-align-center:before { margin: 0 auto; }
            .is-style-asterisk.has-text-align-right:before { margin-left: auto; }
            .rtl .is-style-asterisk.has-text-align-left:before { margin-right: auto; }
        ";

        register_block_style(
            'core/heading',
            array(
                'name'         => 'asterisk',
                'label'        => __( 'With asterisk', 'aiucd-theme' ),
                'inline_style' => $asterisk_style,
            )
        );
    }
endif;

add_action( 'init', 'aiucd_child_block_styles' );

/**
 * STEP 1: Registra la posizione menu 'primary'
 * Anche TT4 (FSE) rispetta register_nav_menus per compatibilità
 */
function aiucd_register_nav_menus() {
    register_nav_menus( array(
        'primary' => __( 'Primary Menu', 'aiucd-theme' ),
    ) );
}
add_action( 'after_setup_theme', 'aiucd_register_nav_menus' );

/**
 * STEP 2: Assegna automaticamente i menu alle lingue
 * Menu IDs:
 * - 25: Header menu IT (italiano)
 * - 37: Header menu EN (inglese)
 */
function aiucd_assign_menus_to_languages() {
    if ( ! function_exists( 'pll_current_language' ) ) {
        return;
    }

    $current_lang = pll_current_language();
    
    // Imposta dinamicamente il menu in base alla lingua
    add_filter( 'theme_mod_nav_menu_locations', function( $locations ) use ( $current_lang ) {
        if ( $current_lang === 'it' ) {
            $locations['primary'] = 25; // Header menu IT
        } elseif ( $current_lang === 'en' ) {
            $locations['primary'] = 37; // Header menu EN
        }
        return $locations;
    } );
}
add_action( 'wp', 'aiucd_assign_menus_to_languages' );
