import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/user.dart';
import '../models/lead.dart';
import '../models/note.dart';
import '../models/statistics.dart';
import '../models/api_response.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // Authentication
  @POST('/auth/register')
  Future<ApiResponse<AuthResponse>> register(
    @Body() Map<String, dynamic> body,
  );

  @POST('/auth/login')
  Future<ApiResponse<AuthResponse>> login(
    @Body() Map<String, dynamic> body,
  );

  @GET('/auth/me')
  Future<ApiResponse<User>> getCurrentUser();

  // Leads
  @GET('/leads')
  Future<ApiResponse<List<Lead>>> getLeads({
    @Query('status') String? status,
    @Query('source') String? source,
  });

  @POST('/leads')
  Future<ApiResponse<Lead>> createLead(
    @Body() Map<String, dynamic> body,
  );

  @GET('/leads/{id}')
  Future<ApiResponse<Lead>> getLead(
    @Path('id') String id,
  );

  @PATCH('/leads/{id}')
  Future<ApiResponse<Lead>> updateLead(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/leads/{id}')
  Future<ApiResponse<void>> deleteLead(
    @Path('id') String id,
  );

  // Notes
  @GET('/leads/{id}/notes')
  Future<ApiResponse<List<Note>>> getLeadNotes(
    @Path('id') String leadId,
  );

  @POST('/leads/{id}/notes')
  Future<ApiResponse<Note>> addNote(
    @Path('id') String leadId,
    @Body() Map<String, dynamic> body,
  );

  // Profile
  @GET('/profile')
  Future<ApiResponse<User>> getProfile();

  @PATCH('/profile')
  Future<ApiResponse<User>> updateProfile(
    @Body() Map<String, dynamic> body,
  );

  // Statistics
  @GET('/stats')
  Future<ApiResponse<Statistics>> getStatistics();
}
