use strict;
use warnings;

package Plack::Middleware::Pjax;
use parent qw/Plack::Middleware/;

use Plack::Util;
use HTML::Marpa;

use Data::Printer;

sub call {
    my ($self, $env) = @_;

    my $res = $self->app->($env);

    Plack::Util::response_cb($res, sub {
        my $res = shift;

        my $h = Plack::Util::headers($res->[1]);
        return unless defined $h->get('HTTP_X_PJAX');

        #my $tag = $h->get('HTTP_X_PJAX_CONTAINER') || 'data-pjax-container';
        my $tag = 'data-pjax-container';

        my $body = [];
        Plack::Util::foreach($res->[2], sub { push @$body, $_[0]; });
        $body = join '', @$body;

        my ($instance, $slice) = @{
            html( \$body, {
                q{title} => sub {
                    Marpa::HTML::original()
                },
                $tag => sub {
                    $Marpa::HTML::INSTANCE->{pjax}++;
                    Marpa::HTML::contents();
                },
                q{*} => sub { undef },
                ':TOP' => sub {
                    [ $Marpa::HTML::INSTANCE, \( join q{}, @{ Marpa::HTML::values() } ) ]
                },
            });
        };

        if ($instance->{pjax}) {
            $res->[2] = [ $body ];
            $h->set('Content-Length', Plack::Util::content_length([ $body ]);
        }

        return $res;
    });
}

1;
