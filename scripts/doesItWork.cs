using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
public struct Point
{
	public int x { get; }
	public int y { get; }
	public Point(int X, int Y)
	{
		this.x = X;
		this.y = Y;
	}
	public bool EqualTo(Point other) {
		return (x == other.x) && (y == other.y);
	}
	// these two methods are here so the compiler stops complaining
	public override int GetHashCode() {
		return 0;
	}
	public override string ToString() => $"({x}, {y})";
}
public struct Line
{
	public Point Point1 { get; }
	public Point Point2 { get; }
	public Line(Point p1, Point p2)
	{
		Point1 = p1;
		Point2 = p2;
	}
	public override string ToString() 
	{
		return "[" + Point1.ToString() + ", " + Point2.ToString() + "]";
	}
}

namespace CSharpTutorials
{
	class Program
	{
		// utilies[i] gives the start-end pair of the ith utility as a Line
		// connections[i] gives all the line connections associated with the ith utility as a List<Line>
		static bool doesItWork(List<Line> utilities, List<List<Line>> connections) 
		{
			// look through each connection
			// see if any of its lines intersect with the lines of all connections after it
			for (int i = 0; i < connections.Count; i++) {
				for (int j = i + 1; j < connections.Count; j++) {
					foreach (Line line_i in connections[i]) {
						foreach (Line line_j in connections[j]) {
							if (doIntersect(line_i, line_j)) {
								// Console.Write(i + " ");
								// Console.WriteLine(line_i.ToString());
								// Console.Write(j + " ");
								// Console.WriteLine(line_j.ToString());
								Console.WriteLine("crossed");
								return false;
							}
						}
					}
				}
			}

			// now see if the utilities connect up
			for (int i = 0; i < utilities.Count; i++) {
				// give each line a version of itself that goes backwards too
				int connection_size = connections[i].Count;
				for (int j = 0; j < connection_size; j++) {
					connections[i].Add(new Line(connections[i][j].Point2, connections[i][j].Point1));
				}
				if (!doesUtilityConnectionWork(utilities[i].Point1, utilities[i].Point2, connections[i])) {
					Console.WriteLine("not connected at: " + i.ToString());
					return false;
				}
			}

			return true;
		}
		// Given three collinear points p, q, r, the function checks if 
		// point q lies on line segment 'pr' 
		static Boolean onSegment(Point p, Point q, Point r) 
		{ 
			if (q.x <= Math.Max(p.x, r.x) && q.x >= Math.Min(p.x, r.x) && 
				q.y <= Math.Max(p.y, r.y) && q.y >= Math.Min(p.y, r.y)) 
			return true; 
		
			return false; 
		} 
		
		// To find orientation of ordered triplet (p, q, r). 
		// The function returns following values 
		// 0 --> p, q and r are collinear 
		// 1 --> Clockwise 
		// 2 --> Counterclockwise 
		static int orientation(Point p, Point q, Point r) 
		{ 
			// See https://www.geeksforgeeks.org/orientation-3-ordered-points/ 
			// for details of below formula. 
			int val = (q.y - p.y) * (r.x - q.x) - 
					(q.x - p.x) * (r.y - q.y); 
		
			if (val == 0) return 0; // collinear 
		
			return (val > 0)? 1: 2; // clock or counterclock wise 
		} 
		
		// The main function that returns true if line segment 'p1q1' 
		// and 'p2q2' intersect. 
		static Boolean doIntersect(Line l1, Line l2) 
		{
			Point p1 = l1.Point1;
			Point q1 = l1.Point2;

			Point p2 = l2.Point1;
			Point q2 = l2.Point2;
			
			// Find the four orientations needed for general and 
			// special cases 
			int o1 = orientation(p1, q1, p2); 
			int o2 = orientation(p1, q1, q2); 
			int o3 = orientation(p2, q2, p1); 
			int o4 = orientation(p2, q2, q1); 
		
			// General case 
			if (o1 != o2 && o3 != o4) 
				return true; 
		
			// Special Cases 
			// p1, q1 and p2 are collinear and p2 lies on segment p1q1 
			if (o1 == 0 && onSegment(p1, p2, q1)) return true; 
		
			// p1, q1 and q2 are collinear and q2 lies on segment p1q1 
			if (o2 == 0 && onSegment(p1, q2, q1)) return true; 
		
			// p2, q2 and p1 are collinear and p1 lies on segment p2q2 
			if (o3 == 0 && onSegment(p2, p1, q2)) return true; 
		
			// p2, q2 and q1 are collinear and q1 lies on segment p2q2 
			if (o4 == 0 && onSegment(p2, q1, q2)) return true; 
		
			return false; // Doesn't fall in any of the above cases 
		} 
		static bool doesUtilityConnectionWork(Point start, Point end, List<Line> connections) 
		{
			// Console.WriteLine(start.ToString());
			// foreach (Line line in connections) Console.Write(line.ToString());

			if (start.EqualTo(end)) return true;
			
			bool works = false;

			foreach (Line line in connections) {
				if (line.Point1.EqualTo(start)) {
					List<Line> new_connections = new List<Line>(connections);
					new_connections.Remove(line);
					works = works || doesUtilityConnectionWork(line.Point2, end, new_connections);
				
				} else if (line.Point2.EqualTo(start)) {
					List<Line> new_connections = new List<Line>(connections);
					new_connections.Remove(line);
					works = works || doesUtilityConnectionWork(line.Point1, end, new_connections);
				} 
			}

			return works;
		}

		// static void Main()
		// {
			
		//     List<Line> utilities = new List<Line>();
		//     utilities.Add(new Line(new Point(1, 1), new Point(3, 5)));
		//     utilities.Add(new Line(new Point(3, 2), new Point(5, 4)));
			
		//     List<Line> connection1 = new List<Line>();
		//     connection1.Add(new Line(new Point(1, 1), new Point(3, 4)));
		//     connection1.Add(new Line(new Point(3, 4), new Point(3, 5)));

		//     // List<Line> connection2 = new List<Line>();
		//     // connection2.Add(new Line(new Point(3, 2), new Point(3, 4)));
		//     // connection2.Add(new Line(new Point(3, 4), new Point(5, 4)));
			
		//     List<Line> connection2 = new List<Line>();
		//     connection2.Add(new Line(new Point(3, 2), new Point(4, 4)));
		//     connection2.Add(new Line(new Point(4, 4), new Point(5, 4)));
			
		//     List<List<Line>> connections = new List<List<Line>>();
		//     connections.Add(connection1);
		//     connections.Add(connection2);

		//     string message = doesItWork(utilities, connections).ToString();
		//     // string message = sample.ToString();

		//     Console.WriteLine(message);
		// }
	}
}
