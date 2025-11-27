import 'dart:io';
import 'dart:convert';

void main() {
  // Carrega as variáveis de ambiente do arquivo .env
  final envFile = File('.env');
  
  if (!envFile.existsSync()) {
    print('❌ Erro: Arquivo .env não encontrado!');
    print('📝 Copie o arquivo .env.example para .env e preencha com suas credenciais.');
    exit(1);
  }

  final envVars = <String, String>{};
  final lines = envFile.readAsLinesSync();
  
  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    
    final parts = line.split('=');
    if (parts.length == 2) {
      envVars[parts[0].trim()] = parts[1].trim();
    }
  }

  // Valida se todas as variáveis necessárias existem
  final requiredVars = [
    'FIREBASE_API_KEY',
    'FIREBASE_PROJECT_NUMBER',
    'FIREBASE_PROJECT_ID',
    'FIREBASE_STORAGE_BUCKET',
    'FIREBASE_MOBILESDK_APP_ID_1',
    'FIREBASE_MOBILESDK_APP_ID_2',
    'FIREBASE_PACKAGE_NAME_1',
    'FIREBASE_PACKAGE_NAME_2',
  ];

  for (var varName in requiredVars) {
    if (!envVars.containsKey(varName) || envVars[varName]!.isEmpty) {
      print('❌ Erro: Variável $varName não encontrada ou vazia no .env');
      exit(1);
    }
  }

  // Gera o conteúdo do google-services.json
  final googleServices = {
    'project_info': {
      'project_number': envVars['FIREBASE_PROJECT_NUMBER'],
      'project_id': envVars['FIREBASE_PROJECT_ID'],
      'storage_bucket': envVars['FIREBASE_STORAGE_BUCKET']
    },
    'client': [
      {
        'client_info': {
          'mobilesdk_app_id': envVars['FIREBASE_MOBILESDK_APP_ID_1'],
          'android_client_info': {
            'package_name': envVars['FIREBASE_PACKAGE_NAME_1']
          }
        },
        'oauth_client': [],
        'api_key': [
          {
            'current_key': envVars['FIREBASE_API_KEY']
          }
        ],
        'services': {
          'appinvite_service': {
            'other_platform_oauth_client': []
          }
        }
      },
      {
        'client_info': {
          'mobilesdk_app_id': envVars['FIREBASE_MOBILESDK_APP_ID_2'],
          'android_client_info': {
            'package_name': envVars['FIREBASE_PACKAGE_NAME_2']
          }
        },
        'oauth_client': [],
        'api_key': [
          {
            'current_key': envVars['FIREBASE_API_KEY']
          }
        ],
        'services': {
          'appinvite_service': {
            'other_platform_oauth_client': []
          }
        }
      }
    ],
    'configuration_version': '1'
  };

  // Salva o arquivo google-services.json
  final outputFile = File('android/app/google-services.json');
  final encoder = JsonEncoder.withIndent('  ');
  outputFile.writeAsStringSync(encoder.convert(googleServices));
  
  print('✅ google-services.json gerado com sucesso!');
  print('📁 Localização: ${outputFile.path}');
}
