using Base
using LinearAlgebra
"""
This is my implementation of basic geometric data structs and functions

Here we have the definition of basic shape's structs sush as point, line, circles, triangles etc 
Also, we have definition of some operations that we would like to do with this basic shapes, such as collision, sums, areas etc
"""

# TODO LIST
    # shapes translation
    # shapes rotatio
    # shapes scalar
# 

# STRUCTS DEFINITIONS================================================================

struct Point
    x::Float64 
    y::Float64 
end

"""
Struct representating a line that starts in point **p1** and finish in point **p2** 

Line is also represented by for  ax + by + c = 0

Example: 
    p2 <------------ p1
"""
struct Line
    p2::Point
    p1::Point
    a::Float64
    b::Float64
    c::Float64
end

struct Rectangle
    p1::Point
    p2::Point
    p3::Point
    p4::Point
    lines::Vector{Line}
end

struct Triangle
    p1::Point
    p2::Point
    p3::Point
    lines::Vector{Line}
end

struct Ngon
    points::Vector{Point}
    sides::Int64
    lines::Vector{Line}
end
# areas :https://www.themathdoctors.org/polygon-coordinates-and-areas/
# collisions http://www.jeffreythompson.org/collision-detection/rect-rect.php

struct Circle
    center::Point
    radius::Float64
end


# Points Operations =================================================================
"""+(p1, p2)
return a POint() with the sum of x and y

Example
    Point(10.0, 20.0) + Point(30.0, 5.0) = Point(40.0, 25.0)
"""
function Base.:+(p1::Point, p2::Point)
    return Point(p1.x+p2.x, p1.y+ p2.y)
end


"""-(p1, p2)
return a Line() starting in p1 and finishing in p2
∣∣∣∣25x14y111∣∣∣∣=0

2⋅4⋅1+1⋅1⋅x+1⋅5⋅y−1⋅4⋅x−2⋅1⋅y−1⋅5⋅1=0

8+x+5y−4x−2y−5=0

−3x+3y+3=0

Note que todos os termos são múltiplos de 3, logo, podemos dividir todos os elementos por 3, encontrando a equação geral da reta:
Example
    Point(10.0, 20.0) - Point(30.0, 5.0) = Line(Point(30.0, 5.0) , Point(10.0, 20.0))
"""
function Base.:-(p1::Point, p2::Point)
    return Line(p2, p1)
end


#Line Operations =================================================================================
"""Line(p1,p2)
Line constructor using 2 forms 

line from p1 to p2

and gerneral line equation: ax + by + c = 0
"""
function Line(p1::Point,p2::Point)
    a = p1.y - p2.y
    b = p2.x - p1.x
    c = p1.x*p2.y - p1.y*p2.x
    return Line(p1, p2, a, b, c)
end

"""abs(l)
return length of a line using pitagora

Example: 
    abs(Line(Point(4,0), Point(0,3))) -> 5.0
"""
function abs(l::Line)
    return sqrt( (l.p1.x - l.p2.x)^2 + (l.p1.y - l.p2.y)^2 )
end

"""angle(l)
return angle in degrees between a line and x axis

Example: 
    angle(Line( p(0,0) ,p(3,3) )) -> 45
"""
function angle(l::Line)
    return atand( l.p1.y - l.p2.y, l.p1.x - l.p2.x )
end

"""angle(l1, l2)
Return the smaller angle between the thow lines (always lower than 180 degrees)
"""
function angle(l1::Line, l2::Line)
    ang = Base.abs(angle(l1) - angle(l2))
    ang = ang > 180 ? 360-ang : ang
    ang = ang == 180 ? 0 : ang
    return ang
end

"""angular_coefficient(l)
returns the angular coeficiente of the Line l using its 2 points
Example: angular_coefficient(Line(p(0,0), p(1,1))) -> 1
"""
function angular_coefficient(l::Line)
    return((l.p2.y - l.p1.y)/(l.p2.x - l.p1.x))
end

"""linear_coefficient(l)
returns the linear coeficiente of the Line l using its 2 points
Example: linear_coefficient(Line(p(0,1), p(1,2))) -> 1
"""
function linear_coefficient(l::Line)
    m = angular_coefficient(l)
    b = l.p1.y + m*-l.p1.x
    return b
end

"""collinear(l1, l2)
returns wether the two lines are collinear or not based on linear and angular coefficients
Example: collinear(p(0,0)-p(1,1), p(1,1)- p(2,2)) -> true
"""
function collinear(l1::Line, l2::Line)
    return l1.a == l2.a && l1.b == l2.b && l1.c == l2.c
end

"""+(p, l)
return a Point that walks from Point p in the Line l

Example
Point(0,0) + Line(Point(0,0) , Point(10,0)) -> Point(10,0)
"""
function Base.:+(p1::Point, l::Line)
    return Point(p1.x +  l.p2.x - l.p1.x, p1.y +  l.p2.y - l.p1.y)
end

"""point_in_line(p,l)
returns wether the Point p is in Line l
"""
function point_in_line(p::Point, l::Line)
    if (l.p1.x<=p.x<=l.p2.x || l.p2.x<=p.x<=l.p1.x)
        y_expected = (-l.a*p.x - l.c)/l.b
        return y_expected == p.y 
    end
    return false
end
# Rectangle Function ===============================================================
"""Rectangle(p1, p2, p3, p4) constructor
returns a Rectangle with point p1,p2,p3 and p4
"""
function Rectangle(p1,p2,p3, p4)
    lines = [p2-p1, p3-p2, p4-p3, p1-p4]
    if angle(lines[1], lines[2]) == angle(lines[2], lines[3]) == angle(lines[4], lines[3]) == angle(lines[4], lines[1]) == 90
        return Rectangle(p1, p2, p3, p4, lines)
    else
        error("Point does not make a real rectangle")
    end
end

"""Rectangle(p1, p2) constructor
returns a Rectangle with **upper left corner in p1** and **bottom right corner in p2** and parallel lines with y and x axis
"""
function Rectangle(p1::Point, p2::Point)
    if (p1.x == p2.x  || p1.y == p2.y)
        error("Points must have x and y coordinates differents")
    end
    p3 = p2
    p2 = Point(p3.x, p1.y)
    p4 = Point(p1.x, p3.y)
    lines = [p2-p1, p3-p2, p4-p3, p1-p4]
    return Rectangle(p1, p2, p3, p4, lines)
end

function area(r::Rectangle)
    l_horizontal = r.p2 - r.p1
    l_vertical = r.p2 - r.p3
    return abs(l_horizontal) * abs(l_vertical)
end

function perimeter(r::Rectangle)
    return sum(abs.(r.lines))
end

# Triangle Function ===============================================================

function Triangle(p1,p2,p3)
    if point_in_line(p1, p3-p2) #maybe change to check coeficientes
        error("3 point must be non collinear")
    end
    
    return Triangle(p1,p2,p3, [p2-p1, p3-p2, p3-p1])

end

function perimeter(t::Triangle)
    return sum(abs.(t.lines))
end

function area(t::Triangle)
    D = [ 
    t.p1.x t.p1.y 1;
    t.p2.x t.p2.y 1;
    t.p3.x t.p3.y 1]
    return Base.abs(det(D))/2
end

# NGON FUNCTIONS =======================================
"""Ngon(ponots...)
Return a Ngon object with the points created
"""
function Ngon(pontos::Point... )
    #TODO -> check if points are collinear
    pontos = collect(pontos)
    lines = []
    for i in 1:length(pontos)-1
        push!(lines, pontos[i+1] - pontos[i]) 
    end
    push!(lines, pontos[end] - pontos[1])
    Ngon(pontos, length(pontos), lines)
end

"""area(ngon)
return the intern area of the polyngon
"""
function area(n::Ngon)
    S1 = 0
    S2 = 0
    for i in 1:n.sides-1
        S1 += n.points[i].x*n.points[i+1].y
    end
    S1 +=n.points[end].x*n.points[1].y

    for i in 1:n.sides-1
        S2 += n.points[i].y*n.points[i+1].x
    end
    S2 +=n.points[end].y*n.points[1].x
    return 1/2*(Base.abs(S1-S2))
end

"""perimeter(ngon)
returns the perimeter of a polyngon
"""
function perimeter(n::Ngon)
    return sum(abs.(n.lines))
end



# Collision functions =====================================================

# Points --------------------------------------------------------------------------------------------------------
"""collision(p1, p2)
return true or false wether the points are collidin or not

Example
    collision(Point(0,0), Point(0,0)) -> true    
    collision(Point(0,0), Point(1,0)) -> false    
"""
function collision(p1::Point, p2::Point)
    return p1.x == p2.x && p1.x == p2.y
end

"""collision(p, l)
return true or false wether the structs are collidin or not

uses value ϵ for numeric error

Example

"""
function collision(p::Point, l::Line, ϵ = 1e-10)
    return abs(l.p1 - p) + abs(l.p2 - p) -  abs(l) < ϵ
end

"""collision(p, c)
return true or false wether the structs are collidin or not

Example

"""
function collision(p::Point, c::Circle)
    return abs(p - c.center) <= c.radius
end

"""collision(p, t)
return true or false wether the structs are collidin or not

based in this video : https://www.youtube.com/watch?v=HYAgJN3x4GA

Example

"""
function collision(p::Point, t::Triangle)
    # return area(t) - (area(Triangle(p, t.p1, t.p2)) + area(Triangle(p, t.p1, t.p3)) + area(Triangle(p, t.p2, t.p3))) < ϵ

    w1 = ( t.p1.x*(t.p3.y-t.p1.y) + (p.y-t.p1.y)*(t.p3.x-t.p1.x) - p.x*(t.p3.y - t.p1.y)) /( (t.p2.y-t.p1.y)*(t.p3.x-t.p1.x) - (t.p2.x-t.p1.x)*(t.p3.y-t.p1.y) )
    w2 = ( p.y - t.p1.y - w1*(t.p2.y-t.p1.y) )/( t.p3.y - t.p1.y )

    return w1 >= 0 && w2 >= 0 && (w1+w2) <= 1
end

"""collision(p, r)
return true or false wether the structs are collidin or not

Example

"""
function collision(p::Point, r::Rectangle)
    t1 = Triangle(r.p1, r.p2, r.p3)
    t2 = Triangle(r.p1, r.p3, r.p4)

    return collision(p,t1) && collision(p, t2)
end

"""collision(p, n)
return true or false wether the structs are collidin or not
Alogithim described here http://www.jeffreythompson.org/collision-detection/poly-point.php
Example

"""
function collision(p::Point, n::Ngon)
    bCollision = false
    
    for i in 1:length(n.points) - 1
        cv = n.points[i] # current vertice
        nv = n.points[i+1] #next vertice

        if ( (cv.y <= p.y) != (nv.y <= p.y) ) && 
        ( p.x < (nv.x-cv.x)*(p.y-cv.y) / (nv.y-cv.y)+cv.x )
            bCollision = !bCollision
        end
    end

    cv = n.points[end]
    nv = n.points[1]
    if ( (cv.y <= p.y) != (nv.y <= p.y) ) && 
    ( p.x < (nv.x-cv.x)*(p.y-cv.y) / (nv.y-cv.y)+cv.x )
        bCollision = bCollision
    end

    return bCollision
end

# Lines --------------------------------------------------------------------------------------------------------
"""collision(l, p)
return true or false wether the structs are collidin or not

Example

"""
function collision(l::Line, p::Point)
    collision(p,l)
end

"""collision(l1, l)
return true or false wether the lines are colliding or not

based in https://web.archive.org/web/20060911055655/http://local.wasp.uwa.edu.au/%7Epbourke/geometry/lineline2d/

Example

"""
function collision(l1::Line, l2::Line)
    denominator = (l2.p2.y-l2.p1.y)*(l1.p2.x-l1.p1.x) - (l2.p2.x-l2.p1.x)*(l1.p2.y-l1.p1.y)
    if denominator == 0 #parallel
        return false
    end

    ua = (l2.p2.x - l2.p1.x)*(l1.p1.y-l2.p1.y) - (l2.p2.y-l2.p1.y)*(l1.p1.x-l2.p1.x)
    ua = ua/denominator
    ub = (l1.p2.x - l1.p1.x)*(l1.p1.y-l2.p1.y) - (l1.p2.y-l1.p1.y)*(l1.p1.x-l2.p1.x)
    ub = ub/denominator
    
    xc = l1.p1.x +ua*(l1.p2.x - l1.p1.x)
    yc = l1.p1.y +ua*(l1.p2.y - l1.p1.y)
    return 0 <= ua <=1 && 0 <= ub <= 1 
end

"""collision(l1, c2)
return true or false wether the structs are collidin or not
based in http://www.jeffreythompson.org/collision-detection/line-circle.php

Example

"""
function collision(l::Line, c::Circle)
    # check if any of the points is inside circle
    if collision(l.p1, c) || collision(l.p2, c)
        return true
    end

    len = abs(l)
    dot = ( (c.center.x-l.p1.x)*(l.p2.x -l.p1.x) + (c.center.y-l.p1.y)*(l.p2.y -l.p1.y) ) / (len^2)
    pline = Point(l.p1.x + dot*(l.p2.x - l.p1.x), l.p1.y + dot*(l.p2.y - l.p1.y)) # closest point to the circle in infinity line (perpendicular to the line)

    # check if pline is inside line 
    if !(collision(pline, l))
        println("pline = $pline")
        return false
    end

    #check if distance betwen line and circle is greater then radius
    if abs(pline - c.center) > c.radius
        println("pline = $pline")
        return false
    end

    return true
end

"""collision(l, t)
return true or false wether the structs are collidin or not

Based in my lazy method -> check collision between each line
Example

"""
function collision(l::Line, t::Triangle)
    for line in t.lines
        if collision(line,l)
            return true
        end
    end
    return false
end

"""collision(l, r)
return true or false wether the structs are collidin or not

Example

"""
function collision(l::Line, r::Rectangle)
    for line in q.lines
        if collision(line,l)
            return true
        end
    end
    return false
end

"""collision(l, n)
return true or false wether the structs are collidin or not

Example

"""
function collision(l::Line, n::Ngon)
    for line in n.lines
        if collision(line,l)
            return true
        end
    end
    return false
end


# Circle --------------------------------------------------------------------------------------------------------
"""collision(c, p)
return true or false wether the structs are collidin or not

Example

"""
function collision(c::Circle, p::Point)
    collision(p, c)
end

"""collision(c, l)
return true or false wether the lines are colliding or not

Example

"""
function collision(c::Circle, l::Line)
    collision(l,c)
end

"""collision(c1, c2)
return true or false wether the structs are collidin or not

Example

"""
function collision(c1::Circle, c2::Circle)
    return abs(c1.center - c2.center) <= c1.radius + c2.radius
end

"""collision(c, t)
return true or false wether the structs are collidin or not

Example

"""
function collision(c::Circle, t::Triangle)
    for line in t.lines
        if collision(line,c)
            return true
        end
    end
    return false
end

"""collision(c, r)
return true or false wether the structs are collidin or not

Example

"""
function collision(c::Circle, r::Rectangle)
    for line in r.lines
        if collision(line,c)
            return true
        end
    end
    return false
end

"""collision(c, n)
return true or false wether the structs are collidin or not

Example

"""
function collision(c::Circle, n::Ngon)
    for line in n.lines
        if collision(line,c)
            return true
        end
    end
    return false
end

# Triangle --------------------------------------------------------------------------------------------------------
"""collision(t, p)
return true or false wether the structs are collidin or not

Example

"""
function collision(t::Triangle, p::Point)
    collision(p,t)
end

"""collision(t, l)
return true or false wether the lines are colliding or not

Example

"""
function collision(t::Triangle, l::Line)
    collision(l,t)
end

"""collision(t, c)
return true or false wether the structs are collidin or not

Example

"""
function collision(t::Triangle, c::Circle)
    collision(c,t)
end

"""collision(t1, t2)
return true or false wether the structs are collidin or not

Example

"""
function collision(t1::Triangle, t2::Triangle)
    for lt1 in t1.lines
        for lt2 in t2.lines
            if collision(lt1,lt2)
                return true
            end
        end
    end
    return false
end

"""collision(t, r)
return true or false wether the structs are collidin or not

Example

"""
function collision(t::Triangle, r::Rectangle)
    for lt in t.lines
        for lr in r.lines
            if collision(lt,lr)
                return true
            end
        end
    end
    return false
end

"""collision(t, n)
return true or false wether the structs are collidin or not

Example

"""
function collision(t::Triangle, n::Ngon)
    for lt in t.lines
        for ln in n.lines
            if collision(lt,ln)
                return true
            end
        end
    end
    return false
end

# Rectangle --------------------------------------------------------------------------------------------------------
"""collision(r, p)
return true or false wether the structs are collidin or not

Example

"""
function collision(r::Rectangle, p::Point)
    collision(p,r)
end

"""collision(r, l)
return true or false wether the lines are colliding or not

Example

"""
function collision(r::Rectangle, l::Line)
    collision(l,r)
end

"""collision(r, c)
return true or false wether the structs are collidin or not

Example

"""
function collision(r::Rectangle, c::Circle)
    collision(c, r)
end

"""collision(r, t)
return true or false wether the structs are collidin or not

Example

"""
function collision(r::Rectangle, t::Triangle)
    collision(t, r)
end

"""collision(r1, r2)
return true or false wether the structs are collidin or not

Example

"""
function collision(r1::Rectangle, r2::Rectangle)
    for lr1 in r1.lines
        for lr2  in r2.lines
            if collision(lr1, lr2)
                return true
            end
        end
    end
    return false
end

"""collision(r, n)
return true or false wether the structs are collidin or not

Example

"""
function collision(r::Rectangle, n::Ngon)
    for lr in r.lines
        for ln in n.lines
            if collision(lr,ln)
                return true
            end
        end
    end
    return false
end


# Ngon --------------------------------------------------------------------------------------------------------
"""collision(n, p)
return true or false wether the structs are collidin or not

Example

"""
function collision(n::Ngon, p::Point)
    collision(p,n)
end

"""collision(n, l)
return true or false wether the lines are colliding or not

Example

"""
function collision(n::Ngon, l::Line)
    collision(l,n)
end

"""collision(n, c)
return true or false wether the structs are collidin or not

Example

"""
function collision(n::Ngon, c::Circle)
    collision(c,n)
end

"""collision(n, t)
return true or false wether the structs are collidin or not

Example

"""
function collision(n::Ngon, t::Triangle)
    collision(t, n)
end

"""collision(n1, n2)
return true or false wether the structs are collidin or not

Example

"""
function collision(n::Ngon, r::Rectangle)
    collision(r, n)
end

"""collision(n1, n2)
return true or false wether the structs are collidin or not

Example

"""
function collision(n1::Ngon, n2::Ngon)
    for ln1 in n1.lines
        for ln2 in n2.lines
            if collision(ln1, ln2)
                return true
            end
        end
    end
    return false
end