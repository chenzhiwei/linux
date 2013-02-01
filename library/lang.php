<?php

main();

function main() {
    set_language();
    test();
}

function test() {
    echo _("Hello, world!") . "<br />";
    echo _("Who are you?") . "<br />";
    echo gettext("I do not tell you!") . "<br />";
    echo '<a href='. $_SERVER['PHP_SELF']. '?lang='.LANG_SWITCH.'>Swith to '.LANG_SWITCH.'</a>';
}

function set_language() {
    $lang = @$_GET['lang'];
    if(!$lang) $lang = @$_SERVER['HTTP_ACCEPT_LANGUAGE'];
    if(preg_match('/en.+us/i', $lang)) {
        $dom = 'en';
        $lang = 'en_US.uft-8';
        define('LANG_SWITCH', 'zh_CN');
    } else {
        $dom = 'zh';
        $lang = 'zh_CN.utf-8';
        define('LANG_SWITCH', 'en_US');
    }
    setlocale(LC_ALL, $lang);
    bindtextdomain($dom, __dir__ . '/lang');
    bind_textdomain_codeset($dom, 'UTF-8');
    textdomain($dom);
}
?>
