import armos;
import rx;
import std.concurrency;
import std.stdio;

class TestApp : ar.BaseApp
{
	this()
	{
		_eventMouseMoved = new SubjectObject!Point;
		_eventMousePressed = new SubjectObject!Point;
		_eventMouseReleased = new SubjectObject!Point;
	}

	void setup(){
		ar.setLineWidth(2);

		//マウスを押したら
		_eventMousePressed.doSubscribe((Point p) {
				auto line = new ar.Mesh;
				line.primitiveMode = ar.PrimitiveMode.LineStrip;
				_lines ~= line;

				//マウスの移動を購読しつつ
				auto disposable = _eventMouseMoved.doSubscribe((Point p) {
						line.addVertex(p.x, p.y, 0);
						line.addIndex(cast(int)line.numVertices-1);
					});
				//上げたときに破棄するよう設定
				_eventMouseReleased.doSubscribe((Point p) {
						disposable.dispose();
					});
			});
		
		_eventMouseMoved.observeOn(new ThreadScheduler)
			.doSubscribe((Point p) {
				writeln(p);
			});
	}

	void update(){}

	void draw(){
		foreach (line; _lines) line.drawWireFrame();
	}

	void keyPressed(int key){}

	void keyReleased(int key){}

	void mouseMoved(int x, int y, int button)
	{
		_eventMouseMoved.put(Point(x, y));
	}

	void mousePressed(ar.Vector2i position, int button)
	{
		_eventMousePressed.put(Point(position[0], position[1]));
	}

	void mouseReleased(ar.Vector2i position, int button)
	{
		_eventMouseReleased.put(Point(position[0], position[1]));
	}

private:
	ar.Mesh[] _lines;
	Subject!Point _eventMouseMoved;
	Subject!Point _eventMousePressed;
	Subject!Point _eventMouseReleased;
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
