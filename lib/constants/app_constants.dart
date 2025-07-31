class AppConstants {
  // API
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  static const String apiVersion = 'v1';
  
  // Endpoints
  static const String authEndpoint = '/auth';
  static const String subjectsEndpoint = '/subjects';
  static const String summariesEndpoint = '/summaries';
  static const String reviewsEndpoint = '/reviews';
  static const String statisticsEndpoint = '/statistics';
  
  // Armazenamento local
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String settingsKey = 'app_settings';
  
  // Configurações de revisão
  static const int defaultReviewInterval = 1; // dias
  static const int maxReviewInterval = 365; // dias
  static const double easeFactor = 2.5;
  static const double minEaseFactor = 1.3;
  
  // Limites
  static const int maxSummaryLength = 10000;
  static const int maxSubjectNameLength = 50;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  
  // Animações
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  
  // Paginação
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cores das matérias (hex)
  static const List<String> subjectColors = [
    '#FF6B6B', // Vermelho
    '#4ECDC4', // Turquesa
    '#45B7D1', // Azul
    '#96CEB4', // Verde
    '#FFEAA7', // Amarelo
    '#DDA0DD', // Roxo
    '#98D8C8', // Verde água
    '#F7DC6F', // Dourado
    '#BB8FCE', // Lavanda
    '#85C1E9', // Azul claro
  ];
  
  // Níveis de dificuldade
  static const Map<int, String> difficultyLevels = {
    1: 'Muito Fácil',
    2: 'Fácil',
    3: 'Médio',
    4: 'Difícil',
    5: 'Muito Difícil',
  };
  
  // Tipos de notificação
  static const String reviewNotificationType = 'review_reminder';
  static const String studyNotificationType = 'study_reminder';
  static const String goalNotificationType = 'goal_reminder';
  
  // Configurações padrão
  static const Map<String, dynamic> defaultSettings = {
    'notifications_enabled': true,
    'review_reminders': true,
    'study_reminders': true,
    'daily_goal': 15,
    'theme_mode': 'system',
    'language': 'pt_BR',
  };
  
  // Regex patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';
  
  // Mensagens de erro
  static const Map<String, String> errorMessages = {
    'network_error': 'Erro de conexão. Verifique sua internet.',
    'server_error': 'Erro no servidor. Tente novamente mais tarde.',
    'invalid_credentials': 'Email ou senha incorretos.',
    'user_not_found': 'Usuário não encontrado.',
    'email_already_exists': 'Este email já está em uso.',
    'weak_password': 'A senha deve ter pelo menos 8 caracteres.',
    'invalid_email': 'Email inválido.',
    'required_field': 'Este campo é obrigatório.',
    'max_length_exceeded': 'Texto muito longo.',
    'file_too_large': 'Arquivo muito grande.',
    'unsupported_format': 'Formato não suportado.',
  };
  
  // Mensagens de sucesso
  static const Map<String, String> successMessages = {
    'login_success': 'Login realizado com sucesso!',
    'register_success': 'Conta criada com sucesso!',
    'summary_created': 'Resumo criado com sucesso!',
    'summary_updated': 'Resumo atualizado com sucesso!',
    'subject_created': 'Matéria criada com sucesso!',
    'review_completed': 'Revisão concluída!',
    'settings_saved': 'Configurações salvas!',
  };
}

