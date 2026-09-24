class ProjectModel {
  final String id;
  final String title;
  final int progress;
  final int document;
  final int comment;
  final DateTime date;
  final List<ProjectMember> members;
  final String colorTheme;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.progress,
    required this.document,
    required this.comment,
    required this.date,
    required this.members,
    required this.colorTheme,
  });
}

class ProjectMember {
  final String id;
  final String name;
  final String? profileImage;

  const ProjectMember({
    required this.id,
    required this.name,
    this.profileImage,
  });
}