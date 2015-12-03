import armos;
import rx;
import std.concurrency;
import std.stdio;

class TestApp : ar.BaseApp
{
	this()
	{
		_eventMouseMoved = new SubjectObject!Point;
	}

	void setup(){
		ar.setLineWidth(2);
		line.primitiveMode = ar.PrimitiveMode.LineStrip;

		_eventMouseMoved.doSubscribe((Point p) {
				line.addVertex(p.x, p.y, 0);
				line.addIndex(cast(int)line.numVertices-1);
			});

		_eventMouseMoved.observeOn(new ThreadScheduler)
			.doSubscribe((Point p) {
				writeln(p);
			});
	}

	void update(){}

	void draw(){
		line.drawWireFrame;
	}

	void keyPressed(int key){}

	void keyReleased(int key){}

	void mouseMoved(int x, int y, int button)
	{
		_eventMouseMoved.put(Point(x, y));
	}

	void mousePressed(ar.Vector2i position, int button){}

	void mouseReleased(ar.Vector2i position, int button){}

private:
	ar.Mesh line = new ar.Mesh;
	Subject!Point _eventMouseMoved;
}

void main()
{
	ar.run(new TestApp);
}

struct Point
{
	size_t x;
	size_t y;
}
