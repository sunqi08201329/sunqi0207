class Edge {
	string name_edge;
	Vertex * src;
	Vertex * dst;
	int cost;
	Edge(const string * n, Vertex * s = NULL, Vertex * d = NULL, int c = 0): name_edge(n),src(s), dst(d), cost(c){}
}
