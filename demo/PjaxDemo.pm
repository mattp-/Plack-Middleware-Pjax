#!/usr/bin/env perl

package PjaxDemo;
use Web::Simple;
use Template;
use Plack::App::Directory;
use Plack::Middleware::Pjax;

my $template = Template->new({
    INCLUDE_PATH => 'views/',
});

sub dispatch_request {
    sub (/) {
        my $out;
        $template->process('index.tt', {}, \$out);
        [ 200, [ 'Content-type', 'text/html' ], [ $out ] ]
    },
    sub (/dinosaurs+.html) {
        my $out;
        $template->process('dinosaurs.tt', {}, \$out);
        [ 200, [ 'Content-type', 'text/html' ], [ $out ] ]
    },
        sub (/aliens+.html) {
        my $out;
        $template->process('aliens.tt', {}, \$out);
        [ 200, [ 'Content-type', 'text/html' ], [ $out ] ]
    },
    sub (/static/...) { Plack::App::Directory->new({ root => "static/" }) },
}

PjaxDemo->run_if_script;
