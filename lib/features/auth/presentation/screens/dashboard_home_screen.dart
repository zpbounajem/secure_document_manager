import 'package:flutter/material.dart';

import 'package:secure_document_manager/features/auth/data/models/project_model.dart';
import 'package:secure_document_manager/features/auth/presentation/widgets/dashboard/dashboard_header.dart';
import 'package:secure_document_manager/features/auth/presentation/widgets/dashboard/dashboard_search_bar.dart';
import 'package:secure_document_manager/features/auth/presentation/widgets/dashboard/folder_card.dart';
import 'package:secure_document_manager/features/auth/presentation/widgets/dashboard/project_cart.dart';
import 'package:secure_document_manager/features/auth/presentation/widgets/dashboard/recent_file_card.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() =>
      _DashboardHomeScreenState();
}

class _DashboardHomeScreenState
    extends State<DashboardHomeScreen> {
  final List<ProjectModel> _projects = [
    ProjectModel(
      id: 'project-1',
      title: 'Website Design',
      progress: 75,
      document: 12,
      comment: 8,
      date: DateTime(2026, 10, 24),
      members: const [
        ProjectMember(
          id: 'member-1',
          name: 'John',
        ),
        ProjectMember(
          id: 'member-2',
          name: 'Sarah',
        ),
        ProjectMember(
          id: 'member-3',
          name: 'Mike',
        ),
      ],
      colorTheme: 'pink',
    ),
  ];

  final List<Map<String, dynamic>> _folders = [
    {
      'name': 'Work',
      'files': 12,
      'progress': 0.72,
      'type': 'green',
    },
    {
      'name': 'Projects',
      'files': 24,
      'progress': 0.55,
      'type': 'blue',
    },
    {
      'name': 'Personal',
      'files': 8,
      'progress': 0.35,
      'type': 'cyan',
    },
    {
      'name': 'Shared',
      'files': 17,
      'progress': 0.80,
      'type': 'purple',
    },
  ];

  final List<Map<String, dynamic>> _recentFiles = [
    {
      'name': 'Project Proposal.pdf',
      'type': 'PDF',
      'size': '2.4 MB',
      'date': 'Today, 10:42 AM',
      'icon': Icons.picture_as_pdf_rounded,
    },
    {
      'name': 'Project Documents',
      'type': 'Folder',
      'size': '12 files',
      'date': 'Yesterday',
      'icon': Icons.folder_rounded,
    },
    {
      'name': 'Company Report.docx',
      'type': 'DOCX',
      'size': '1.8 MB',
      'date': 'Sep 18, 2026',
      'icon': Icons.description_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFEEECFA),
            Color(0xFFE4E7F8),
            Color(0xFFF6F5FC),
          ],
          stops: [
            0.0,
            0.35,
            0.70,
            1.0,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardHeader(),

              const SizedBox(height: 22),

              const DashboardSearchBar(),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Projects',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF17151B),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8068A8),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              ..._projects.map(
                (project) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: ProjectCard(
                    project: project,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Folders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF17151B),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8068A8),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: _folders.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.25,
                ),
                itemBuilder: (context, index) {
                  final folder = _folders[index];

                  return FolderCard(
                    name: folder['name'],
                    files: folder['files'],
                    progress: folder['progress'],
                    type: folder['type'],
                  );
                },
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Files',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF17151B),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8068A8),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              ..._recentFiles.map(
                (file) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: RecentFileCard(
                    name: file['name'],
                    type: file['type'],
                    size: file['size'],
                    date: file['date'],
                    icon: file['icon'],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}