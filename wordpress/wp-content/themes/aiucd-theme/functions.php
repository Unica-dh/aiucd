<?php
/**
 * AIUCD Theme child functions
 */

if ( ! function_exists( 'aiucd_child_enqueue_parent_style' ) ) {
    function aiucd_child_enqueue_parent_style() {
        wp_enqueue_style( 'twentytwentyfour-parent-style', get_template_directory_uri() . '/style.css' );
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
