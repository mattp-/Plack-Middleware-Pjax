#
# This file is part of Plack-Middleware-Pjax
#
# This software is copyright (c) 2011 by Matthew Phillips.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use strict;
use warnings;

package Plack::Middleware::Pjax;
{
  $Plack::Middleware::Pjax::VERSION = '1.113390';
}
# ABSTRACT: PJAX for your Plack
use parent qw/Plack::Middleware/;


use Plack::Util;
use Plack::Request;
use Marpa::HTML;

sub call {
    my ($self, $env) = @_;

    my $res = $self->app->($env);

    Plack::Util::response_cb($res, sub {
        my $req = Plack::Request->new($env);
        my $res = shift;

        return unless defined $req->header('x-pjax');
        my $tag = $req->header('x-pjax-container') || 'data-pjax-container';

        my $body = [];
        Plack::Util::foreach($res->[2], sub { push @$body, $_[0]; });
        $body = join '', @$body;

        my $stripped = Marpa::HTML::html( \$body,{
            q{*} => sub {
                if (Marpa::HTML::attributes()->{$tag}) {
                    push @{$Marpa::HTML::INSTANCE->{stripped}}, Marpa::HTML::contents();
                }
            },
            q{title} => sub {
                unshift @{$Marpa::HTML::INSTANCE->{stripped}}, Marpa::HTML::original();
            },
            ':TOP' => sub {
                $Marpa::HTML::INSTANCE->{stripped} || [];
            }
        });

        # if length is 0 or 1, there was no pjax container in the body,
        #  so just return the original
        if (@$stripped > 0) {
            $res->[2] = [join '', @$stripped];
            my $h = Plack::Util::headers($res->[1]);
            # recalculate content length after changing it
            $h->set('Content-Length', Plack::Util::content_length($res->[2]));
        }

        return $res;
    });
}

1;

__END__
=pod

=head1 NAME

Plack::Middleware::Pjax - PJAX for your Plack

=head1 VERSION

version 1.113390

=head1 SYNOPSIS

    use Plack::Builder;
    builder {
        enable 'Plack::Middleware::Pjax';
        $app
    }

=head1 DESCRIPTION

Plack::Middleware::Pjax adds easy support for serving chromeless pages in combination with jquery-pjax. For more information on what pjax is, check the SEE ALSO links below.

It does this by filtering the generated response through L<Marpa::HTML>. If the x-pjax http header is set, only the title and InnerHTML of the pjax-container are sent to the client.

Although you take a small processing hit adding an html parsing pass into the response cycle, using L<Plack::Middleware::Pjax> saves you from adding any view specific logic in your plack applications.

See demo/ in the dist directory for a plack port of L<http://pjax.heroku.com/>

Thanks to the authors of rack-pjax, as it is the source of inspiration (also docs and tests) for the creation of this module.

=head1 DETAILS

    <head>
      ...
      <script src="/javascripts/jquery.js"></script>
      <script src="/javascripts/jquery.pjax.js"></script>
      <script type="text/javascript">
        $(function(){
          $('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])').pjax('[data-pjax-container]')
        })
      </script>
      ...
    </head>
    <body>
      <div data-pjax-container>
        ...
      </div>
    </body>

Include the above in your applications layout wrapper. When any link is hit with a <pushstate|http://caniuse.com/#search=pushstate/> enabled browser, L<Plack::Middleware::Pjax> will turn a fragment like:
    <title>foo</title>
    bar baz

=head1 SEE ALSO

=for :list * L<https://github.com/eval/rack-pjax>
* L<Marpa::HTML>
* L<http://pjax.heroku.com/>
* L<https://github.com/defunkt/jquery-pjax>

=head1 AUTHOR

Matthew Phillips <mattp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Matthew Phillips.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

