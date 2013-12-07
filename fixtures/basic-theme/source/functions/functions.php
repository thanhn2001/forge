<?php

add_action( 'wp_enqueue_scripts', 'basic-theme_enqueue_scripts' );

if ( ! function_exists( 'basic-theme_enqueue_scripts' ) ) :

/**
* Add theme styles and scripts here
*/
function basic-theme_enqueue_scripts() {

	if ( ! is_admin() ) {
		wp_enqueue_style(
			'basic-theme-style',
			get_bloginfo( 'stylesheet_url' )
		);
	}

}

endif; // basic-theme_enqueue_scripts

add_action( 'after_setup_theme', 'basic-theme_setup' );

if ( ! function_exists( 'basic-theme_setup' ) ) :

/**
* Set up your theme here
*/
function basic-theme_setup() {
	add_theme_support( 'post-thumbnails' );
}

endif; // basic-theme_setup
