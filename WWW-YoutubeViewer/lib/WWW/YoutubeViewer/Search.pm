package WWW::YoutubeViewer::Search;

sub _get_search_url{
    my($self) = @_;
    return $self->prepare_url($self->get_feeds_url() . 'search');
}

sub _search{
    my($self, $type, $keywords) = @_;

    my $q = $self->escape_string("@{$keywords}");

    my $url = $self->_concat_args(
    $self->_get_search_url(),
        part=>'snippet',
        q => $q,
        type => $type,
    );

    return $self->lwp_get($url);
}

=head2 search_videos(@keywords)

Search and return the video results.

=cut

sub search_videos{
    my ($self, @keywords) = @_;
    return $self->_search('videos', \@keywords);
}

1;

__END__
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
