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


library algorithm.boundary_node_rule;

/**
 * An interface for various rules which determine
 * whether node points are in boundarys of [Lineal]
 * geometry components are in the boundary of the parent
 * geometry collection.
 */
typedef bool VertexInBoundaryRule(int boundaryCount);

/**
 * Utility method for setting the default boundaryRule from an optional
 * parameter.
 *
 * The *OGC SFS* default boundary rule is the [MOD2_BOUNDARY_RULE]
 */
const VertexInBoundaryRule OGC_BOUNDARY_RULE = MOD2_BOUNDARY_RULE;



/**
 * Specifies that points are in the boundary of a geometry
 * iff the point lies on the boundary of an odd number
 * of components.
 *
 * Under this rule, [Ring]s and closed [Linestring]s
 * have an empty boundary.
 *
 * This is the rule specified by the *OGC SFS*, and is the
 * default rule in [:spatially:]
 */
const VertexInBoundaryRule MOD2_BOUNDARY_RULE = _mod2BoundaryRule;
bool _mod2BoundaryRule(int boundaryCount) => boundaryCount % 2 == 1;

/**
 * Specifies that any points which are endpoints
 * of [Lineal] components are in the boundary of the
 * parent geometry.
 *
 * Under this rule [Ring]s have a non-empty boundary
 * (the common endpoint of the underlying [Linestring]).
 *
 * When dealing with linear networks, the usual network
 * topology constraint is that linear segments may only
 * touch at endpoints.
 *
 * In the case of a segment touching a [Ring] at a single
 * point, the [:MOD2_BOUNDARY_RULE:] cannot distinguish
 * between the permitted case of touching at the node
 * and the invalid case of touching at some other interior
 * (non-node) point.
 * The endpoint rule does distinguish between these cases,
 * so is more appropriate for this situation
 */
final VertexInBoundaryRule ENDPOINT_BOUNDARY_RULE = _endpointBoundaryRule;
bool _endpointBoundaryRule(int boundaryCount) => boundaryCount > 0;

/**
 * A [BounaryNodeRule] which determines that endpoints
 * with valency greater than 1 are on the boundary.
 *
 * This corresponds to the boundary of a [MultiLinestring]
 * being all the "attached" endpoints, but not the
 * "unattached" ones
 */
final VertexInBoundaryRule MULTIVALENT_ENDPOINT_BOUNDARY_RULE = _multivalentEndpointRule;
bool _multivalentEndpointRule(int boundaryCount) => boundaryCount > 1;

/**
 * A [VertexInBoundaryRule] which determines that only endpoints
 * with a valency of exactly 1 are on the boundary.
 *
 * This corresponds to the boundary of a [MultiLinestring]
 * being all the "unattached" ones.
 */
final VertexInBoundaryRule MONOVALENT_ENDPOINT_BOUNDARY_RULE = _monovalentEndpointRule;
bool _monovalentEndpointRule(int boundaryCount) => boundaryCount == 1;

