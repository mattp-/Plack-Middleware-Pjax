#!/usr/bin/perl

use Plack;
use Plack::Builder;
use PjaxDemo;

builder {
    enable 'Plack::Middleware::Pjax';
    mount '/' => PjaxDemo->run_if_script;
}
