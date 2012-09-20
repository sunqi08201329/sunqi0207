class Graph {
	vector<Vertex> VertexSet;
	vector<Edge> EdgeSet;
public:
	Graph();
	Graph(vector<Vertex> vertexs, Vertex<Edge> edges);
	~Graph();

	bool IsEmpty();
	
	void InsertVertex(const Vertex& vertex);
	void InsertEdge(const Edge& edge);

	void DeleteVertex(Vertex & vertex);
	void DelteEdge(Edge& edge);

	Vertex * getVertex(const string& nv);
	Edge * getEdge(const string & ne);

	int getEdgeValue(Edge& edge);
	Vertex * getEdgeSrc(Edge& edge);
	Vertex * getEdgeDst(Edge& edge);
	Vertex * getFirstAdjVex(Vertex & Vertex);
	Vertex * getNextAdjVex(Vertex & Vertex);

	void DFSTraverse(Vertex& vertex);
	void BFSTraverse(Vertex& vertex);

	vector<Edge*> getShortPath(Vertex& vertex1, Vertex& vertex2);
}
