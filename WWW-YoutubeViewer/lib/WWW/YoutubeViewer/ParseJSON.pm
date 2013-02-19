package WWW::YoutubeViewer::ParseJSON;

use strict;
use autouse 'JSON::XS' => qw(decode_json);

=head1 NAME

WWW::YoutubeViewer::ParseJSON - Parse JSON content.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use WWW::YoutubeViewer::ParseJSON;
    my $obj = WWW::YoutubeViewer::ParseJSON->new(%opts);

=head1 SUBROUTINES/METHODS

=cut

=head2 parse_json_string($json_string)

Parse a JSON string and return a HASH ref.

=cut

sub parse_json_string {
    return decode_json($_[1]);
}

my $json = <<'JSON';
{
 "kind": "youtube#searchListResponse",
 "etag": "\"O7gZuruiUnq-GRpzm3HckV3Vx7o/sliVBqkyAMku3cBpVMsXW1ZpPfg\"",
 "pageInfo": {
  "totalResults": 1000000,
  "resultsPerPage": 5
 },
 "nextPageToken": "CAUQAA",
 "items": [
  {
   "id": {
    "kind": "youtube#video",
    "videoId": "tAp2qVa5kH0"
   },
   "kind": "youtube#searchResult",
   "etag": "\"O7gZuruiUnq-GRpzm3HckV3Vx7o/-6VRyUpB-G3JEP_kv4OjfegLX7s\"",
   "snippet": {
    "publishedAt": "2012-04-04T23:48:06.000Z",
    "channelId": "UC69y0hZJEiF_drrxE50VLTQ",
    "title": "New Voice Activated Google Goggles High Tech Invention \"Project Glass\"",
    "description": "Project Glass: One day... video demonstrating \"Google Goggles\" www.youtube.com ... hodgetwins ... hodgetwins Google Project Glass \"Project Glass ...",
    "thumbnails": {
     "default": {
      "url": "https://i.ytimg.com/vi/tAp2qVa5kH0/default.jpg"
     },
     "medium": {
      "url": "https://i.ytimg.com/vi/tAp2qVa5kH0/mqdefault.jpg"
     },
     "high": {
      "url": "https://i.ytimg.com/vi/tAp2qVa5kH0/hqdefault.jpg"
     }
    }
   }
  },
  {
   "id": {
    "kind": "youtube#video",
    "videoId": "K6ULfctnffw"
   },
   "kind": "youtube#searchResult",
   "etag": "\"O7gZuruiUnq-GRpzm3HckV3Vx7o/ccgNdxqk6DLEGwWiyIU3QRdWD58\"",
   "snippet": {
    "publishedAt": "2013-02-13T11:37:00.000Z",
    "channelId": "UCrYHlDr5mShQ8uJxkpgJDRA",
    "title": "George Ferris interactive Google Doodle [HQ]",
    "description": "There is a Google Doodle on February 14th, 2013. It's Valentine's Day today. Google celebrate this day with a worldwide Google Doodle. They honor ...",
    "thumbnails": {
     "default": {
      "url": "https://i.ytimg.com/vi/K6ULfctnffw/default.jpg"
     },
     "medium": {
      "url": "https://i.ytimg.com/vi/K6ULfctnffw/mqdefault.jpg"
     },
     "high": {
      "url": "https://i.ytimg.com/vi/K6ULfctnffw/hqdefault.jpg"
     }
    }
     }
  },
  {
   "id": {
    "kind": "youtube#video",
    "videoId": "KPlFdzRtl9k"
   },
   "kind": "youtube#searchResult",
   "etag": "\"O7gZuruiUnq-GRpzm3HckV3Vx7o/AnbrL0Bv3TlgguGO0sCldVhUixM\"",
   "snippet": {
    "publishedAt": "2011-07-09T01:40:15.000Z",
    "channelId": "UCo0vVHI3Oz7O5zTc6f-5lgw",
    "title": "Use Your Google Maps Offline!",
     "description": "GeekBeat.TV is looking for tech reviewers, the iPad might be getting a professional version, Android users can use Google Maps offline, and more ...",
    "thumbnails": {
     "default": {
      "url": "https://i.ytimg.com/vi/KPlFdzRtl9k/default.jpg"
     },
     "medium": {
      "url": "https://i.ytimg.com/vi/KPlFdzRtl9k/mqdefault.jpg"
     },
    "high": {
      "url": "https://i.ytimg.com/vi/KPlFdzRtl9k/hqdefault.jpg"
     }
    }
   }
  },
  {
   "id": {
    "kind": "youtube#video",
    "videoId": "9s4lFahJaro"
   },
   "kind": "youtube#searchResult",
   "etag": "\"O7gZuruiUnq-GRpzm3HckV3Vx7o/Q_ZpEuqkvL83XXB6uYIP_GJwSaI\"",
   "snippet": {
   "publishedAt": "2013-02-18T17:27:56.000Z",
    "channelId": "UCeF2CDLLS7gRsU1G2tIWoiw",
    "title": "Video Ranking Formula [FREE] - How To Get Your Videos on Google Page 1 In 24 Hours",
    "description": "Let your videos earn you 100% commissions - Logicblogger.com Want to rank your videos on the first page of Google fast?... In this complete video ...",
    "thumbnails": {
     "default": {
      "url": "https://i.ytimg.com/vi/9s4lFahJaro/default.jpg"
     },
     "medium": {
      "url": "https://i.ytimg.com/vi/9s4lFahJaro/mqdefault.jpg"
     },
     "high": {
      "url": "https://i.ytimg.com/vi/9s4lFahJaro/hqdefault.jpg"
     }
    }
   }
  },
  {
   "id": {
    "kind": "youtube#video",
    "videoId": "iOJF0sniCS4"
   },
   "kind": "youtube#searchResult",
   "etag": "\"O7gZuruiUnq-GRpzm3HckV3Vx7o/6Z-_hXqjneNKqucBUZG5Mn-itgM\"",
   "snippet": {
    "publishedAt": "2013-02-18T18:44:22.000Z",
    "channelId": "UCpwndeSqXsHFdSbTSQ9YZIA",
   "title": "Free Google Play Gift Cards!",
    "description": "To join, click the following link tinyurl.com ... \"how to\" get free google play \"google play\" \"gift cards\" giftcards \"wii points\" \"nintendo eshop ...",
    "thumbnails": {
     "default": {
      "url": "https://i.ytimg.com/vi/iOJF0sniCS4/default.jpg"
     },
     "medium": {
      "url": "https://i.ytimg.com/vi/iOJF0sniCS4/mqdefault.jpg"
     },
     "high": {
      "url": "https://i.ytimg.com/vi/iOJF0sniCS4/hqdefault.jpg"
     }
    }
   }
  }
 ]
}
JSON

=head1 AUTHOR

Suteu "Trizen" Daniel, C<< <trizenx at gmail.com> >>


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::YoutubeViewer::ParseJSON


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Suteu "Trizen" Daniel.

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

1;    # End of WWW::YoutubeViewer::ParseJSON
