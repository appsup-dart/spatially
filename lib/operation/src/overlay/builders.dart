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


part of spatially.operation.overlay;

abstract class _OverlayBuilder {
  static int _getDim(Geometry g) {
    if (g is Point || g is MultiPoint) {
      return 1;
    } else if (g is Linestring || g is MultiLinestring) {
      return 2;
    } else if (g is Polygon || g is MultiPolygon) {
      return 3;
    } else if (g is GeometryList) {
      return g.fold(1, (d,g) => math.max(d, _getDim(g)));
    }
    throw new GeometryError("Not a recognised geometry type");
  }

  final GeometryGraph graph;
  final GeometryFactory geomFactory;
  final int overlayType;

  _OverlayBuilder._(GeometryGraph graph,
                   int this.overlayType) :
    this.graph = graph,
    geomFactory = graph.geometries.$1.factory;

  factory _OverlayBuilder(GeometryGraph graph,
                         int overlayType) {
    var dims = graph.geometries.map<int>((v)=>_getDim(v));
    var dim;
    switch(overlayType) {
      case OVERLAY_INTERSECTION:
      case OVERLAY_DIFFERENCE:
        //Take the minimum dimension
        dim = math.min(dims.$1, dims.$2);
        break;
      case OVERLAY_UNION:
      case OVERLAY_SYMMETRIC_DIFFERENCE:
        dim = math.max(dims.$1, dims.$2);
        break;
      default:
        throw new ArgumentError("Invalid overlay type");
    }

    switch(dim) {
      case 1:
        return new _PointBuilder(graph, overlayType);
      case 2:
        return new _LinestringBuilder(graph, overlayType);
      case 3:
        return new _PolygonBuilder(graph, overlayType);
      default:
        throw new StateError("Should never happen");
    }
  }


  bool _inOverlay(Tuple<int,int> onLocations) {
    switch(overlayType) {
      case OVERLAY_INTERSECTION:
        return _inIntersection(onLocations);
      case OVERLAY_UNION:
        return _inUnion(onLocations);
      case OVERLAY_DIFFERENCE:
        return _inDifference(onLocations);
      case OVERLAY_SYMMETRIC_DIFFERENCE:
        return _inSymmetricDifference(onLocations);
      default:
        throw new ArgumentError("Invalid overlay type ($overlayType)");
    }
  }
  Geometry build();
}
