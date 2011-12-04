use strict;
use warnings;

package Plack::Middleware::Pjax;
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

        return unless defined $req->header('HTTP_X_PJAX');

        my $tag = $req->header('HTTP_X_PJAX_CONTAINER') || 'data-pjax-container';

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
