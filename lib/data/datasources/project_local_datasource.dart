import 'package:delemon/data/models/project_model.dart';
import 'package:hive/hive.dart';

class ProjectLocalDatasource {
  static const String _boxName="projectBox";

  Future<Box<ProjectModel>> _openBox()async{
    return await Hive.openBox<ProjectModel>(_boxName);
    
  }


  Future<void> addProject(ProjectModel project) async{
    final box=await _openBox();
    await box.put(project.id, project);
  }


  Future<List<ProjectModel>> getProjects()async{
    final box = await _openBox();
    return box.values.toList();
  }


  Future<ProjectModel?> getProject(String id) async {
    final box = await _openBox();
    return box.get(id);
  }

  Future<void> updateProject(ProjectModel project) async {
    final box = await _openBox();
    await box.put(project.id, project);
  }

  Future<void> deleteProject(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

}