# -*- coding: utf-8 -*-

# Based on photon.py by Osmo Salomaa.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

"""
Geocoding using Google's Open Location Code(Plus Codes).
https://github.com/google/open-location-code
"""

import copy
import poor
import urllib.parse

URL = ("https://plus.codes/api?"
       "key=" + poor.key.get("PLUSCODES_APIKEY") +
       "&address={query}"
       "&language={lang}")

URL_REVERSE = ("https://plus.codes/api?"
       "key=" + poor.key.get("PLUSCODES_APIKEY") +
       "&address={lat},{lng}"
       "&language={lang}")
cache = {}

def autocomplete(query, x=0, y=0, params={}):
    """Return a list of autocomplete dictionaries matching `query`."""
    if len(query) < 6: return []
    results = geocode(query=query, x=x, y=y, params=params)
    return results

def geocode(query, x=0, y=0, params={}):
    """Return a list of dictionaries of places matching `query`."""
    query = urllib.parse.quote_plus(query)
    lang = poor.util.get_default_language("en")
    url = URL.format(**locals())
    print(url)
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    results = poor.http.get_json(url)['plus_code']
    results = [dict(
        title=parse_title(results),
        description=results['global_code'],
        x=float(results['geometry']['location']['lng']),
        y=float(results['geometry']['location']['lat']),
    ) for result in range(1)]
    if results and results[0]:
        cache[url] = copy.deepcopy(results)
    return results
    return results

def parse_description(result):
    """Parse description from geocoding result."""
    items = []

    with poor.util.silent(Exception):
        items.append(result['locality']['local_address'])
    return ", ".join(items) or ""

def parse_title(result):
    """Parse title from geocoding result."""
    items = []

    with poor.util.silent(Exception):
        items.append(result['local_code'])
        items.append(result['locality']['local_address'])
    return " ".join(items) or ""

def reverse(x, y, radius, limit=25, params={}):
    """Return a list of dictionaries of places nearby given coordinates."""
    lng = x
    lat = y
    lang = poor.util.get_default_language("en")
    url = URL_REVERSE.format(**locals())
    with poor.util.silent(KeyError):
        return copy.deepcopy(cache[url])
    results = poor.http.get_json(url)['plus_code']
    results = [dict(
        title=parse_title(results),
        label=parse_description(results),
        description=results['global_code'],
        x=float(results['geometry']['location']['lng']),
        y=float(results['geometry']['location']['lat']),
    ) for result in range(1)]
    
    if results and results[0]:
        cache[url] = copy.deepcopy(results)
    return results
