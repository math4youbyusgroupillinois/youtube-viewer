package WWW::YoutubeViewer;

use utf8;
use strict;

use lib '../';    # devel only
use warnings;

use parent qw(
  WWW::YoutubeViewer::Search
  WWW::YoutubeViewer::Videos
  WWW::YoutubeViewer::Channels
  WWW::YoutubeViewer::Playlists
  WWW::YoutubeViewer::ParseJSON
  WWW::YoutubeViewer::Subscriptions
  WWW::YoutubeViewer::PlaylistItems
  WWW::YoutubeViewer::Authentication
  WWW::YoutubeViewer::VideoCategories
  WWW::YoutubeViewer::GuideCategories
  );

use autouse 'URI::Escape' => qw{ uri_escape uri_escape_utf8 uri_unescape };

=head1 NAME

WWW::YoutubeViewer - A very easy interface to YouTube.

=head1 VERSION

Version 0.05

=cut

our $VERSION = '0.05';

=head1 SYNOPSIS

    use WWW::YoutubeViewer;

    my $yv_obj = WWW::YoutubeViewer->new();
    ...

=head1 SUBROUTINES/METHODS

=cut

our @feeds_IDs = qw(top_rated top_favorites most_shared most_popular
  most_recent most_discussed most_responded recently_featured on_the_web);

our @movie_IDs = qw(most_popular most_recent trending);

our @categories_IDs = qw(Film Autos Music Animals Sports Travel Games
  People Comedy Entertainment News Howto Education Tech Nonprofit Movies Trailers);

our @region_IDs = qw(
  AR AU BR CA CZ FR DE GB HK HU IN IE IL
  IT JP MX NL NZ PL RU ZA KR ES SE TW US
  );

our @feed_methods = qw(newsubscriptionvideos recommendations favorites watch_history);

my %valid_options = (

    # Main options
    page       => {valid => [qr/^(?!0+\z)\d+\z/],       default => 1},
    http_proxy => {valid => [qr{^http://}],             default => undef},
    hl         => {valid => [qr/^[a-z]{2}-[A-Z]{2}\z/], default => undef},

    maxResults      => {valid => [1 .. 50],                             default => 2},
    regionCode      => {valid => [qr/^[A-Z]{2}\z/],                     default => undef},
    topicId         => {valid => [qr/^./],                              default => undef},
    order           => {valid => [qw(date rating relevance viewCount)], default => undef},
    publishedAfter  => {valid => [qr/^\d+/],                            default => undef},
    publishedBefore => {valid => [qr/^\d+/],                            default => undef},
    channelId       => {valid => [qr/^[-\w]{2,}\z/],                    default => undef},

    # Video only options
    videoCaption    => {valid => [qw(closedCaption none)],     default => undef},
    videoDefinition => {valid => [qw(high standard)],          default => undef},
    videoCategoryId => {valid => \@categories_IDs,             default => undef},
    videoDimension  => {valid => [qw(2d 3d)],                  default => undef},
    videoDuration   => {valid => [qw(short medium long)],      default => undef},
    videoEmbeddable => {valid => [qw(true)],                   default => undef},
    videoLicense    => {valid => [qw(creativeCommon youtube)], default => undef},
    videoSyndicated => {valid => [qw(true)],                   default => undef},

    #category    => {valid => \@categories_IDs,                           default => undef},
    #region      => {valid => \@region_IDs,                               default => undef},
    #order       => {valid => [qw(date rating relevance viewCount)],      default => undef},
    #time        => {valid => [qw(today this_week this_month all_time)],  default => undef},
    #safe_search => {valid => [qw(strict moderate none)],                 default => undef},

    # Others
    debug       => {valid => [0 .. 2],     default => 0},
    lwp_timeout => {valid => [qr/^\d+\z/], default => 1},
    key         => {valid => [qr/^.{5}/],  default => undef},
    app_version => {valid => [qr/^v?\d/],  default => $VERSION},
    app_name    => {valid => [qr/^./],     default => 'Youtube Viewer'},
    config_dir  => {valid => [qr/^./],     default => q{.}},

    # Booleans
    lwp_keep_alive => {valid => [1, 0], default => 1},
    lwp_env_proxy  => {valid => [1, 0], default => 1},
    escape_utf8    => {valid => [1, 0], default => 0},

    # OAuth stuff
    client_id     => {valid => [qr/^.{5}/], default => undef},
    client_secret => {valid => [qr/^.{5}/], default => undef},
    redirect_uri  => {valid => [qr/^.{5}/], default => undef},
    access_token  => {valid => [qr/^.{5}/], default => undef},
    refresh_token => {valid => [qr/^.{5}/], default => undef},

    # No input value alowed
    categories_url    => {valid => q[], default => 'http://gdata.youtube.com/schemas/2007/categories.cat'},
    educategories_url => {valid => q[], default => 'http://gdata.youtube.com/schemas/2007/educategories.cat'},

    #feeds_url         => {valid => q[], default => 'http://gdata.youtube.com/feeds/api'},
    feeds_url        => {valid => q[], default => 'https://www.googleapis.com/youtube/v3/'},
    video_info_url   => {valid => q[], default => 'http://www.youtube.com/get_video_info'},
    oauth_url        => {valid => q[], default => 'https://accounts.google.com/o/oauth2/'},
    video_info_args  => {valid => q[], default => '?video_id=%s&el=detailpage&ps=default&eurl=&gl=US&hl=en'},
    www_content_type => {valid => q[], default => 'application/x-www-form-urlencoded'},

    # LWP user agent
    lwp_agent => {valid => [qr/^.{5}/], default => 'Mozilla/5.0 (X11; U; Linux i686; en-US) Chrome/10.0.648.45'},
);

{
    no strict 'refs';

    foreach my $key (keys %valid_options) {

        if (ref $valid_options{$key}{valid} eq 'ARRAY') {

            # Create the 'set_*' subroutines
            *{__PACKAGE__ . '::set_' . $key} = sub {
                my ($self, $value) = @_;
                $self->{$key} =
                    $value ~~ $valid_options{$key}{valid}
                  ? $value
                  : $valid_options{$key}{default};
            };
        }

        # Create the 'get_*' subroutines
        *{__PACKAGE__ . '::get_' . $key} = sub {
            return $_[0]->{$key};
        };
    }
}

=head2 new(%opts)

Returns a blessed object.

=cut

sub new {
    my ($class, %opts) = @_;

    my $self = bless {}, $class;

    foreach my $key (keys %valid_options) {
        if (ref $valid_options{$key}{valid} ne 'ARRAY') {
            $self->{$key} = $valid_options{$key}{default};
        }
        else {
            my $code = \&{"set_$key"};
            $self->$code(delete $opts{$key});
        }
    }

    # $self->{start_index} =
    #      delete($opts{start_index})
    #   || $self->get_start_index()
    #   || 1;

    foreach my $invalid_key (keys %opts) {
        warn "Invalid key: '${invalid_key}'";
    }

    return $self;
}

=head2 set_prefer_https($bool)

Will use https:// protocol instead of http://.

=cut

sub set_prefer_https {
    my ($self, $bool) = @_;
    $self->{prefer_https} = $bool;

    foreach my $key (grep /_url\z/, keys %valid_options) {
        next if $key ~~ [qw(oauth_url feeds_url)];
        my $url = $valid_options{$key}{default};
        $self->{prefer_https} ? ($url =~ s{^http://}{https://}) : ($url =~ s{^https://}{http://});
        $self->{$key} = $url;
    }

    return $bool;
}

=head2 get_prefer_https()

Will return the value of prefer_https.

=cut

sub get_prefer_https {
    my ($self) = @_;
    return $self->{prefer_https};
}

=head2 escape_string($string)

Escapes a string with URI::Escape and returns it.

=cut

sub escape_string {
    my ($self, $string) = @_;

    if ($self->get_escape_utf8) {
        utf8::decode($string);
    }

    my $escaped =
      $self->get_escape_utf8()
      ? uri_escape_utf8($string)
      : uri_escape($string);

    return $escaped;
}

=head2 list_to_gdata_arguments(\%options)

Returns a valid string of arguments, with defined values.

=cut

sub list_to_gdata_arguments {
    my ($self, $opts) = @_;
    return join(q{&} => map "$_=$opts->{$_}", grep defined $opts->{$_}, keys %{$opts});
}

=head2 default_gdata_arguments()

Returns a string with the default gdata arguments.

=cut

sub default_gdata_arguments {
    my ($self, $args) = @_;

    my %defaults = (
                    key         => $self->get_key,
                    part        => 'snippet',
                    prettyPrint => 'false',
                    maxResults  => $self->get_maxResults,
                   );

    delete @defaults{keys %{$args}};    # delete already specified pairs (if any)

    $self->list_to_gdata_arguments(\%defaults);
}

=head2 set_lwp_useragent()

Intializes the LWP::UserAgent module and returns it.

=cut

sub set_lwp_useragent {
    my ($self) = @_;

    binmode *STDOUT, ":encoding(UTF-8)";

    require LWP::UserAgent;
    $self->{lwp} = 'LWP::UserAgent'->new(
                                         keep_alive => $self->get_lwp_keep_alive,
                                         env_proxy  => (defined($self->get_http_proxy) ? 0 : $self->get_lwp_env_proxy),
                                         timeout    => $self->get_lwp_timeout,
                                         show_progress => $self->get_debug,
                                         agent         => $self->get_lwp_agent,
                                        );

    $self->{lwp}->ssl_opts(Timeout => 3);
    push @{$self->{lwp}->requests_redirectable}, 'POST';
    $self->{lwp}->proxy('http', $self->get_http_proxy) if (defined($self->get_http_proxy));
    return $self->{lwp};
}

=head2 prepare_access_token()

Returns a string. used as header, with the access token.

=cut

sub prepare_access_token {
    my ($self) = @_;

    if (defined(my $auth = $self->get_access_token)) {
        return "Bearer $auth";
    }

    return;
}

sub _get_lwp_header {
    my ($self) = @_;

    my %lwp_header;
    if (defined $self->get_access_token) {
        $lwp_header{'Authorization'} = $self->prepare_access_token;
    }

    return %lwp_header;
}

=head2 lwp_get($url)

Get and return the content for $url.

=cut

sub lwp_get {
    my ($self, $url) = @_;

    $self->{lwp} // $self->set_lwp_useragent();
    my $response = $self->{lwp}->get($url, $self->_get_lwp_header);

    if ($response->is_success) {
        return $response->decoded_content;
    }
    else {
        my $status = $response->status_line;

        if ($status =~ /^401 / and defined($self->get_refresh_token)) {
            if (defined(my $refresh_token = $self->oauth_refresh_token())) {
                if (defined $refresh_token->{access_token}) {

                    $self->set_access_token($refresh_token->{access_token});

                    # Don't be tempted to use recursion here, because bad things will happen!
                    my $new_resp = $self->{lwp}->get($url, $self->_get_lwp_header);

                    if ($new_resp->is_success) {
                        return $new_resp->decoded_content;
                    }
                    elsif ($new_resp->status_line() =~ /^401 /) {
                        $self->set_refresh_token();    # refresh token was invalid
                        $self->set_access_token();     # access token is also broken
                        warn "[!] Can't refresh the access token! Logging out...\n";
                    }
                    else {
                        warn '[' . $new_resp->status_line . "] Error occured on URL: $url\n";
                    }
                }
                else {
                    warn "[!] Can't get the access_token! Logging out...\n";
                    $self->set_refresh_token();
                    $self->set_access_token();
                }
            }
            else {
                warn "[!] Invalid refresh_token! Logging out...\n";
                $self->set_refresh_token();
                $self->set_access_token();
            }
        }
        print $response->decoded_content;
        warn '[' . $response->status_line . "] Error occured on URL: $url\n";
    }

    return;
}

=head2 lwp_post($url, [@args])

Post and return the content for $url.

=cut

sub lwp_post {
    my ($self, $url, @args) = @_;

    $self->{lwp} // $self->set_lwp_useragent();

    my $response = $self->{lwp}->post($url, @args);

    if ($response->is_success) {
        return $response->decoded_content;
    }
    else {
        warn '[' . $response->status_line() . "] Error occurred on URL: $url\n";
    }

    return;
}

=head2 lwp_mirror($url, $output_file)

Downloads the $url into $output_file. Returns true on success.

=cut

sub lwp_mirror {
    my ($self, $url, $name) = @_;

    $self->{lwp} // $self->set_lwp_useragent();

    my %lwp_header = $self->_get_lwp_header();
    my $response = $self->{lwp}->mirror($url, $name);

    if ($response->is_success) {
        return 1;
    }
    else {
        warn '[' . $response->status_line() . "] Error occured on URL: $url\n";
    }

    return;
}

sub _get_results {
    my ($self, $url) = @_;

    return
      scalar {
              url     => $url,
              results => $self->parse_json_string($self->lwp_get($url)),
             };
}

sub _url_doesnt_contain_arguments {
    my ($self, $url) = @_;
    return 1 if $url =~ m{^https?+://[\w-]++(?>\.[\w-]++)++(?>/[\w-]++)*+/?+$};
    return;
}

=head2 prepare_url($url)

Accepts a URL without arguments, appends the
C<default_arguments()> to it, and returns it.

=cut

sub prepare_url {
    my ($self, $url, $args) = @_;

    # If the URL doesn't contain any arguments, set defaults
    if ($self->_url_doesnt_contain_arguments($url)) {
        $url .= '?' . $self->default_gdata_arguments($args);
    }
    else {
        warn "Invalid url: $url";
    }

    return $url;
}

sub _make_feed_url {
    my ($self, $path, %args) = @_;
    my $url = $self->prepare_url($self->get_feeds_url() . $path, \%args);
    return $self->_concat_args($url, \%args);
}

=head2 get_videos_from_category($cat_id)

Returns a list of videos from a categoryID.

=cut

sub get_videos_from_category {
    my ($self, $cat_id) = @_;

    # NEEDS WORK!!!
}

=head2 get_courses_from_category($cat_id)

Get the courses from a specific category ID.
$cat_id can be any valid category ID from the EDU categories.

=cut

sub get_courses_from_category {
    my ($self, $cat_id) = @_;

    # NEEDS WORK!!!
}

=head2 get_video_lectures_from_course($course_id)

Get the video lectures from a specific course ID.
$course_id can be any valid course ID from the EDU categories.

=cut

sub get_video_lectures_from_course {
    my ($self, $course_id) = @_;

    # NEEDS WORK!!!
}

=head2 get_video_lectures_from_category($cat_id)

Get the video lectures from a specific category ID.
$cat_id can be any valid category ID from the EDU categories.

=cut

sub get_video_lectures_from_category {
    my ($self, $cat_id) = @_;

    # NEEDS WORK!!!
}

=head2 get_movies($movieID)

Get movie results for C<$movieID>.

=cut

sub get_movies {
    my ($self, $movie_id) = @_;

    unless ($movie_id ~~ \@movie_IDs) {
        warn "Invalid movie ID: $movie_id";
        return;
    }

    # http://gdata.youtube.com/feeds/api/charts/movies/most_popular

    my $url = $self->_make_feed_url("/charts/movies/$movie_id");

    return {
            url     => $url,
            results => $self->get_content($url),
           };
}

=head2 get_video_tops(%opts)

Returns the video tops for a specific feed_id.

=cut

sub get_video_tops {
    my ($self, %opts) = @_;

    # NEEDS WORK!!!
}

sub _concat_args {
    my ($self, $url, $opts) = @_;

    return $url if keys(%{$opts}) == 0;
    my $args = $self->list_to_gdata_arguments($opts);

    if (not defined($args) or $args eq q{}) {
        return $url;
    }

    $url =~ s/[&?]+$//;
    $url .= ($url =~ /[&?]/ ? '&' : '?') . $args;
    return $url;
}

sub _get_pairs_from_info_data {
    my ($self, $content) = @_;

    my @array;
    my $i = 0;

    foreach my $block (split(/,/, $content)) {
        foreach my $pair (split(/&/, $block)) {
            $pair =~ s{^url_encoded_fmt_stream_map=(?=\w+=)}{}im;
            my ($key, $value) = split(/=/, $pair);
            $key // next;
            $array[$i]->{$key} = uri_unescape($value);
        }
        ++$i;
    }

    foreach my $hash_ref (@array) {
        if (exists $hash_ref->{url} and exists $hash_ref->{sig}) {

            # Add signature
            $hash_ref->{url} .= "&signature=$hash_ref->{sig}";

            # Add proxy (if defined http_proxy)
            if (defined(my $proxy_url = $self->get_http_proxy)) {
                $proxy_url =~ s{^http://}{http_proxy://};
                $hash_ref->{url} = $proxy_url . $hash_ref->{url};
            }

        }
    }

    return @array;
}

=head2 get_streaming_urls($videoID)

Returns a list of streaming URLs for a videoID.
({itag=>...}, {itag=>...}, {has_cc=>...})

=cut

sub get_streaming_urls {
    my ($self, $videoID) = @_;

    my $url = ($self->get_video_info_url() . sprintf($self->get_video_info_args(), $videoID));

    my $content = uri_unescape($self->lwp_get($url) // return);
    my @info = $self->_get_pairs_from_info_data($content);

    if ($self->get_debug == 2) {
        require Data::Dump;
        Data::Dump::pp(\@info);
    }

    if (exists $info[0]->{status} and $info[0]->{status} eq q{fail}) {
        warn "\n[!] Error occurred on getting info for video ID: $videoID\n";
        my $reason = $info[0]->{reason};
        $reason =~ tr/+/ /s;
        warn "[*] Reason: $reason\n";
        return;
    }
    return grep { (exists $_->{itag} and exists $_->{url} and exists $_->{type}) or exists $_->{has_cc} } @info;
}

=head2 full_gdata_arguments(;%opts)

Returns a string with all the GData arguments.

Optional, you can specify in C<$opts{ignore}>
an ARRAY_REF with the keys that should be ignored.

=cut

sub full_gdata_arguments {
    my ($self, %opts) = @_;

    my %hash = (
        'q' => $opts{keywords} // q{},

        #'max-results' => $self->get_results,
        maxResults   => $self->get_results,
        pageToken    => $opts{page_token},
        regionCode   => $self->get_region,
        videoCaption => $self->get_video_caption,

        #type         => $opts{type},
        #'category'    => $self->get_category,
        # 'time'        => $self->get_time,
        #'orderby'     => $self->get_orderby,
        order => $self->get_order,

        #'start-index' => $self->get_start_index,
        #'safeSearch'  => $self->get_safe_search,
        #'hd'          => $self->get_hd,
        #'caption'     => $self->get_caption,
        #'duration'    => $self->get_duration,
        channelId => $self->get_channel_id,

        #'author'      => $self->get_author,
        #'v'           => $self->get_v,
               );

    if (ref $opts{ignore} eq 'ARRAY') {
        delete @hash{@{$opts{ignore}}};
    }

    return $self->list_to_gdata_arguments(\%hash);
}

=head2 send_rating_to_video($videoID, $rating)

Send rating to a video. $rating can be either 'like' or 'dislike'.

=cut

sub send_rating_to_video {
    my ($self, $code, $rating) = @_;

    # NEEDS WORK!!!
}

=head2 send_comment_to_video($videoID, $comment)

Send comment to a video. Returns true on success.

=cut

sub send_comment_to_video {
    my ($self, $code, $comment) = @_;

    # NEEDS WORK!!!
}

=head2 favorite_video($videoID)

Favorite a video. Returns true on success.

=cut

sub favorite_video {
    my ($self, $code) = @_;

    # NEEDS WORK!!!
}

=head2 like_video($videoID)

Like a video. Returns true on success.

=cut

sub like_video {
    my ($self, $code) = @_;

    # NEEDS WORK!!!
}

=head2 dislike_video($videoID)

Dislike a video. Returns true on success.

=cut

sub dislike_video {
    my ($self, $code) = @_;

    # NEEDS WORK!!!
}

=head2 get_video_comments($videoID)

Returns a list of comments for a videoID.

=cut

sub get_video_comments {
    my ($self, $code) = @_;

    # NEEDS WORK!!!
}

=head2 get_disco_videos(\@keywords)

Search for a disco playlist and return its videos, if any. Undef otherwise.

=cut

sub get_disco_videos {
    my ($self, $keywords) = @_;

    @{$keywords} || return;

    my $url  = 'http://www.youtube.com/disco?action_search=1&query=';
    my $json = $self->lwp_get($url . $self->escape_string("@{$keywords}"));

    if ($json =~ /list=(?<playlist_id>[\w\-]+)/) {
        my $hash_ref = $self->videos_from_playlistID($+{playlist_id});
        $hash_ref->{playlistID} = $+{playlist_id};
        return $hash_ref;
    }

    return;
}

=head2 get_video_info($videoID)

Returns informations for a videoID.

=cut

sub get_video_info {
    my ($self, $id) = @_;

    # NEEDS WORK!!!
}

# SOUBROUTINE FACTORY
{
    no strict 'refs';

    # Create some simple subroutines
    foreach my $method (
                        ['related_videos', '/videos/%s/related', {}],
                        ['playlists_from_username',        '/users/%s/playlists', {playlists => 1}],
                        ['videos_from_username',           '/users/%s/uploads',   {}],
                        ['favorited_videos_from_username', '/users/%s/favorites', {}],
                        ['videos_from_playlist',           '/playlists/%s',       {}],
      ) {

        *{__PACKAGE__ . '::get_' . $method->[0]} = sub {
            my ($self, $id) = @_;
            my $url = $self->prepare_url($self->get_feeds_url() . sprintf($method->[1], $id));
            return {
                    url     => $url,
                    results => $self->get_content($url, %{$method->[2]}),
                   };
        };
    }

    # Create {next,previous}_page subroutines
    foreach my $name ('next_page', 'previous_page') {

        *{__PACKAGE__ . '::' . $name} = sub {
            my ($self, $url, $token) = @_;
            my $res = $self->_get_results($self->_concat_args($url, {pageToken => $token}));
            $res->{url} = $url;
            return $res;
        };
    }

    # Create subroutines that require authentication
    foreach my $method (@feed_methods) {

        *{__PACKAGE__ . '::get_' . $method} = sub {

            my ($self, $user) = @_;
            $user ||= 'default';

            if (not defined $self->get_access_token) {
                if ($user ne 'default' and $method ~~ [qw(newsubscriptionvideos favorites)]) {
                    ## ok
                }
                else {
                    warn "\n[!] The method 'get_$method' requires authentication!\n";
                    return;
                }
            }

            my $url = $self->prepare_url($self->get_feeds_url() . "/users/$user/$method");
            return {
                    url     => $url,
                    results => $self->get_content($url),
                   };
        };
    }
}

=head2 next_page($url;%opts)

Returns the next page of results.
%opts are the same as for I<get_content()>.

=head2 previous_page($url;%opts)

Returns the previous page of results.
%opts are the same as for I<get_content()>.

=head2 get_related_videos($videoID)

Returns the related videos for a videoID.

=head2 get_favorites(;$user)

Returns the latest favorited videos for the current logged user.

=head2 get_recommendations()

Returns a list of videos, recommended for you by Youtube.

=head2 get_watch_history(;$user)

Returns the latest videos watched on Youtube.

=head2 get_newsubscriptionvideos(;$user)

Returns the videos from the subscriptions for the current logged user.

=head2 get_favorited_videos_from_username($username)

Returns the latest favorited videos for a given username.

=head2 get_playlists_from_username($username)

Returns a list of playlists created by $username.

=head2 get_videos_from_playlist($playlistID)

Returns a list of videos from playlistID.

=head2 get_videos_from_username($username)

Returns the latest videos uploaded by a username.

=head2 set_app_name($appname)

Set the application name.

=head2 get_app_name()

Returns the application name.

=head2 set_app_version($version)

Set the application version.

=head2 get_app_version()

Returns the application version.

=head2 get_v()

Returns the current version of GData implementation.

=head2 set_key($dev_key)

Set the developer key.

=head2 get_key()

Returns the developer key.

=head2 set_client_id($client_id)

Set the OAuth 2.0 client ID for your application.

=head2 get_client_id()

Returns the I<client_id>.

=head2 set_client_secret($client_secret)

Set the client secret associated with your I<client_id>.

=head2 get_client_secret()

Returns the I<client_secret>.

=head2 set_redirect_uri($redirect_uri)

A registered I<redirect_uri> for your client ID.

=head2 get_redirect_uri()

Returns the I<redirect_uri>.

=head2 set_access_token($token)

Set the 'Bearer' token type key.

=head2 get_access_token()

Get the 'Bearer' access token.

=head2 set_refresh_token($refresh_token)

Set the I<refresh_token>. This value is used to
refresh the I<access_token> after it expires.

=head2 get_refresh_token()

Returns the I<refresh_token>

=head2 get_www_content_type()

Returns the B<Content-Type> header value used for GData.

=head2 set_author($username)

Set the author value.

=head2 get_author()

Returns the author value.

=head2 set_duration($duration_id)

Set duration value. (ex: long)

=head2 get_duration()

Returns the duration value.

=head2 set_orderby()

Set the order-by value. (ex: published)

=head2 get_orderby()

Returns the orderby value.

=head2 set_hd($value)

Set hd value. $value can be either 'true' or undef.

=head2 get_hd()

Returns the hd value.

=head2 set_caption($value)

Set the caption value. ('true', 'false' or undef)

=head2 get_caption()

Returns caption value.

=head2 set_category($cat_id)

Set a category value. (ex: 'Music')

=head2 get_category()

Returns the category value.

=head2 set_safe_search($value)

Set the safe search sensitivity. (ex: strict)

=head2 get_safe_search()

Returns the safe_search value.

=head2 set_region($region_ID)

Set the regionID value for video tops. (ex: JP)

=head2 get_region()

Returns the region value.

=head2 set_time($time_id)

Set the time value. (ex: this_week)

=head2 get_time()

Returns the time value.

=head2 set_results([1-50])

Set the number of results per page. (max 50)

=head2 get_results()

Returns the results value.

=head2 set_page($i)

Set the page number value.

=head2 get_page()

Returns the page value.

=head2 set_categories_language($cat_lang)

Set the categories language. (ex: en-US)

=head2 get_categories_language()

Returns the categories language value.

=head2 get_categories_url()

Returns the YouTube categories URL.

=head2 get_educategories_url()

Returns the EDU YouTube categories URL.

=head2 set_debug($level_num)

Set the debug level. (valid: 0, 1, 2)

=head2 get_debug()

Returns the debug value.

=head2 set_config_dir($dir)

Set a configuration directory.

=head2 get_config_dir()

Get the configuration directory.

=head2 set_escape_utf8($bool)

If true, it escapes the keywords using uri_escape_utf8.

=head2 get_escape_utf8()

Returns true if escape_utf8 is used.

=head2 get_feeds_url()

Returns the GData feeds URL.

=head2 set_http_proxy($value)

Set http_proxy value. $value must be a valid URL or undef.

=head2 get_http_proxy()

Returns the http_proxy value.

=head2 set_lwp_agent($agent)

Set a user agent for the LWP module.

=head2 get_lwp_agent()

Returns the user agent value.

=head2 set_lwp_env_proxy($bool)

Set the env_proxy value for LWP.

=head2 get_lwp_env_proxy()

Returns the env_proxy value.

=head2 set_lwp_keep_alive($bool)

Set the keep_alive value for LWP.

=head2 get_lwp_keep_alive()

Returns the keep_alive value.

=head2 set_lwp_timeout($sec).

Set the timeout value for LWP, in seconds. Default: 60

=head2 get_lwp_timeout()

Returns the timeout value.

=head2 get_oauth_url()

Returns the OAuth URL.

=head2 get_video_info_url()

Returns the video_info URL.

=head2 get_video_info_args()

Returns the video_info arguments.

=head1 AUTHOR

Suteu "Trizen" Daniel, C<< <trizenx at gmail.com> >>

=head1 SEE ALSO

https://developers.google.com/youtube/2.0/developers_guide_protocol_api_query_parameters

=head1 LICENSE AND COPYRIGHT

Copyright 2012-2013 Trizen.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;    # End of WWW::YoutubeViewer

__END__
