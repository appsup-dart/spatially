//This file is part of Spatially.
//
//    Spatially is free software: you can redistribute it and/or modify
//    it under the terms of the GNU Lesser General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    Spatially is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public License
//    along with Spatially.  If not, see <http://www.gnu.org/licenses/>.



//TODO: support for features?
/**
 * Codec for converting GeoJson geometries to spatially [Geometry] objects.
 *
 * All GeoJSON objects are supported, except `Feature` and `FeatureCollection` objects.
 */
library spatially.convert.geojson;

import 'dart:convert';

import 'package:spatially/base/coordinate.dart';
import 'package:spatially/base/envelope.dart';
import 'package:spatially/geom/base.dart';

/**
 * Provides support for encoding [Geometry] objects as [JSON] strings.
 * Does not support [GeoJson] `"Feature"` or `"FeatureCollection"` type objects.
 * If the `'crs'` or `'bbox'` field is set on the [GeoJSON] geometry, it is ignored
 * by the codec.
 */

//TODO: Figure out how to support features and featurecollection objects in a sane way.
//      Also, crs and bbox on objects.
class GeoJsonCodec extends Codec<Geometry,String> {
  GeometryFactory _geomFactory;
  GeoJsonCodec(GeometryFactory this._geomFactory);

  Converter<String,Geometry> get decoder =>
      new GeoJsonDecoder(_geomFactory);

  Converter<Geometry,String> get encoder => new GeoJsonEncoder();
}

class GeoJsonEncoder extends Converter<Geometry,String> {
  GeoJsonEncoder();

  String convert(Geometry geom) {
    return JSON.encode(geometryToEncodable(geom));
  }

  Map<String,dynamic> geometryToEncodable(Geometry geometry) {
    Map<String,dynamic> encodable = new Map<String,dynamic>();
    encodable['type'] = geometryType(geometry);
    if (geometry is GeometryList
        && geometry is! MultiPoint
        && geometry is! MultiLinestring
        && geometry is! MultiPolygon) {
      encodable['geometries'] = geometry.map(geometryToEncodable).toList(growable: false);
    } else {
      encodable['coordinates'] = _encodeGeometryCoordinates(geometry);
    }
    return encodable;
  }

  String geometryType(Geometry geometry) =>
    Geometry.dispatchToType(geometry,
        applyPoint: (_) => "Point",
        applyLinestring: (_) => "LineString",
        applyPolygon: (_) => "Polygon",
        applyMultiPoint: (_) => "MultiPoint",
        applyMultiLinestring: (_) => "MultiLineString",
        applyMultiPolygon: (_) => "MultiPolygon",
        applyGeometryList: (_) =>"GeometryCollection");

  _encodePointCoordinates(Point p) {
    return _encodeCoordinate(p.coordinate);
  }

  _encodeLinestringCoordinates(Linestring lstr) {
   return lstr.coordinates
       .map(_encodeCoordinate)
         .toList(growable: false);
  }

  _encodePolygonCoordinates(Polygon p) {
    var polyCoords = new List();
    polyCoords.add(_encodeLinestringCoordinates(p.exteriorRing));
    p.interiorRings.forEach(
        (r) => polyCoords.add(_encodeLinestringCoordinates(r)));
    return polyCoords;
  }

  _encodeGeometryCoordinates(Geometry g) {
    return Geometry.dispatchToType(g,
        applyPoint: _encodePointCoordinates,
        applyLinestring: _encodeLinestringCoordinates,
        applyPolygon: _encodePolygonCoordinates,
        applyMultiPoint:
          (mpoint) => mpoint.map(_encodePointCoordinates).toList(),
        applyMultiLinestring:
          (mlstr) => mlstr.map(_encodeLinestringCoordinates).toList(),
        applyMultiPolygon: (mpoly) =>
            mpoly.map(_encodePolygonCoordinates).toList(),
        applyGeometryList:
          (glist) => throw new UnsupportedError("encode geometry list coordinates"));
  }

  _encodeCrs(String crs) {
    //TODO: crs encoding
    throw new UnimplementedError();
  }

  _encodeBbox(Envelope bbox) {
    //TODO: bbox encoding
    throw new UnimplementedError();
  }
  _encodeCoordinate(Coordinate c) {
    if (c.is2d) {
      return [c.x, c.y];
    } else if (c.m.isNaN) {
      return [c.x, c.y, c.z];
    } else {
      return [c.x, c.y, c.z, c.m];
    }
  }
}

class GeoJsonDecoder extends Converter<String,Geometry> {
  GeometryFactory geomFactory;

  GeoJsonDecoder(this.geomFactory);

  Geometry convert(String str, {dynamic reviver(var key, var value)}) {
    return _decodeGeometry(JSON.decode(str));
  }


  //TODO: Better error handling
  _decodeGeometry(Map<String,dynamic> json) {
    if (!json.containsKey('type')) {
      throw new FormatException("No 'type' key on top level geoJSON object");
    }
    switch(json['type']) {
      case 'FeatureCollection':
      case 'Feature':
        throw new FormatException("GeoJSON features not supported by codec");
      case 'Point':
        return _decodePoint(json);
      case 'LineString':
        return _decodeLinestring(json);
      case 'Polygon':
        return _decodePolygon(json);
      case 'MultiPoint':
        return _decodeMultiPoint(json);
      case 'MultiLineString':
        return _decodeMultiLinestring(json);
      case 'MultiPolygon':
        return _decodeMultiPolygon(json);
      case 'GeometryCollection':
        return _decodeGeometryCollection(json);
      default:
        throw new FormatException("Unrecognizable geometry type: ${json['type']}");
    }
  }

  _decodeGeometryCollection(Map<String,dynamic> json) {
    var geoms = json['geometries'];
    if (geoms == null) {
      throw new FormatException("GeometryCollection object must have a 'geometries' entry");
    }
    return  geomFactory.createGeometryList(
        (json['geometries'] as List).map((v)=>_decodeGeometry(v)));
  }

  List _safeCoords(Map<String,dynamic> json) {
    var coords = json['coordinates'];
    if (coords == null)
      throw new FormatException("GeoJSON geometry must have entry for 'coordinates'");
    return coords;
  }

  _decodePoint(Map<String,dynamic> json) =>
    geomFactory.createPoint(_decodeCoordinate(_safeCoords(json)));

  _decodeLinestring(Map<String,dynamic> json) =>
      geomFactory.createLinestring(_decodeCoordinateList(_safeCoords(json)));

  _decodePolygon(Map<String,dynamic> json) {
    var rings = _decodeRings(_safeCoords(json));
    return geomFactory.createPolygon(rings.first, rings.skip(1));
  }

  Iterable<Ring> _decodeRings(List ringCoords) =>
      ringCoords
      .map((v)=>_decodeCoordinateList(v))
      .map(geomFactory.createRing);

  _decodeMultiPoint(Map<String,dynamic> json) =>
      geomFactory.createMultiPoint(_safeCoords(json)
          .map((v)=>_decodeCoordinate(v))
          .map(geomFactory.createPoint));

  _decodeMultiLinestring(Map<String,dynamic> json) =>
      geomFactory.createMultiLinestring(
          _safeCoords(json)
          .map((v)=>_decodeCoordinateList(v))
          .map(geomFactory.createLinestring));

  _decodeMultiPolygon(Map<String,dynamic> json) =>
      geomFactory.createMultiPolygon(
          _safeCoords(json)
          .map((v)=>_decodeRings(v))
          .map((rings) => geomFactory.createPolygon(rings.first, rings.skip(1))));

  Iterable<Coordinate> _decodeCoordinateList(List positionList) =>
      positionList.map((v)=>_decodeCoordinate(v));

  Coordinate _decodeCoordinate(List position) {
    switch(position.length) {
      case 0:
      case 1:
        throw new StateError("Too few elements in position: $position");
      case 2:
        return new Coordinate(position[0], position[1]);
      case 3:
        return new Coordinate(position[0], position[1], position[2]);
      case 4:
        return new Coordinate(position[0], position[1], position[2], position[3]);
      default:  //TODO: truncate?
        throw new StateError("Spatially only supports coordinates with 2 or 3 dimensions");
    }
  }
}