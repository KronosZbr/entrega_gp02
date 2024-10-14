import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Tarefa 01: Função para buscar a lista de posts
Future<List<Post>> fetchPosts() async {
  final response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((post) => Post.fromJson(post)).toList();
  } else {
    throw Exception('Falha ao carregar os posts');
  }
}

// Tarefa 02: Função para buscar o post específico
Future<Post> fetchPost(int id) async {
  final response = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'));

  if (response.statusCode == 200) {
    return Post.fromJson(json.decode(response.body));
  } else if (response.statusCode == 404) {
    throw Exception('Post não encontrado (Erro 404)');
  } else {
    throw Exception('Falha ao carregar o post');
  }
}

// Classe Post
class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  Post(
      {required this.userId,
      required this.id,
      required this.title,
      required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navegação e Assíncrono',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PostsPage(),
    );
  }
}

// Tarefa 01: Página inicial com a lista de posts
class PostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Posts'),
      ),
      body: FutureBuilder<List<Post>>(
        future: fetchPosts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Cast explícito para evitar o erro
            List<Post> posts = snapshot.data as List<Post>;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(posts[index].title),
                  subtitle: Text('Usuário: ${posts[index].userId}'),
                  onTap: () {
                    // Tarefa 02: Navega para a página de detalhes
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PostDetailPage(postId: posts[index].id),
                      ),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

// Tarefa 02: Página de detalhes do post
class PostDetailPage extends StatelessWidget {
  final int postId;

  // Construtor usando `required` para o parâmetro nomeado
  PostDetailPage({required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Post $postId'),
      ),
      body: FutureBuilder<Post>(
        future: fetchPost(postId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snapshot
                        .data!.title, // O operador `!` garante que não é nulo
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(snapshot
                      .data!.body), // O operador `!` garante que não é nulo
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
