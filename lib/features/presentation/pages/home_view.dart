import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart'; 

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _fetchData(WeatherNotifier notifier) {
    if (_formKey.currentState!.validate()) {
      final double lat = double.tryParse(_latitudeController.text) ?? 0.0;
      final double lon = double.tryParse(_longitudeController.text) ?? 0.0;
      notifier.fetchWeather(lat, lon);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 2. Escuchamos al Notifier para reaccionar a los cambios de estado (clima, carga, error)
    final notifier = context.watch<WeatherNotifier>();
    final state = notifier.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima por Coordenadas'),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildBody(context, notifier, state),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherNotifier notifier, state) {
    
    if (state.isLoading) {
      return const CircularProgressIndicator();
    }
    
    // Si hay un fallo, muestra el mensaje de error y un botón para reintentar.
    if (state.failure != null) {
      return _buildErrorWidget(notifier, state.failure!.message);
    }

    // Si hay datos del clima, muéstralos.
    if (state.weather != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Temperatura: ${state.weather!.temperature}°C', style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => notifier.resetState(),
            child: const Text('Hacer otra consulta'),
          )
        ],
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          
          const Text(
            'Latitud', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _latitudeController,
            decoration: const InputDecoration(
              hintText: 'Ej: 16.63 (Suchiapa)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              suffixIcon: Icon(Icons.location_on_outlined),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || double.tryParse(value) == null) {
                return 'Ingresa una Latitud válida.';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 25),
          
          // --- Título y Campo de Longitud ---
          const Text(
            'Longitud', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _longitudeController,
            decoration: const InputDecoration(
              hintText: 'Ej: -93.10 (Suchiapa)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              suffixIcon: Icon(Icons.location_on),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || double.tryParse(value) == null) {
                return 'Ingresa una Longitud válida.';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 30),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _fetchData(notifier),
              icon: const Icon(Icons.search),
              label: const Text('Buscar Clima'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar errores de forma clara
  Widget _buildErrorWidget(WeatherNotifier notifier, String? message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 60),
        const SizedBox(height: 20),
        Text(message ?? 'Ocurrió un error desconocido.', textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => notifier.resetState(),
          child: const Text('Volver a intentar'),
        ),
      ],
    );
  }
}