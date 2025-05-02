import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/country_model.dart';
import '../theme/app_theme.dart';
import '../widgets/base_page.dart';

class MapPage extends StatefulWidget {
  final CountryModel country;

  const MapPage({super.key, required this.country});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapController _mapController;
  double _zoom = 5.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _openInGoogleMaps() async {
    if (widget.country.latlng.length >= 2) {
      final lat = widget.country.latlng[0];
      final lng = widget.country.latlng[1];
      final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d\'ouvrir Google Maps')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Vérifier si le pays a des coordonnées valides
    if (widget.country.latlng.length < 2) {
      return BasePage(
        title: "Carte de ${widget.country.name}",
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                "Coordonnées non disponibles",
                style: AppTheme.subheadingStyle,
              ),
              const SizedBox(height: 8),
              const Text(
                "Les coordonnées géographiques de ce pays ne sont pas disponibles.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Retour"),
              ),
            ],
          ),
        ),
      );
    }

    final lat = widget.country.latlng[0];
    final lng = widget.country.latlng[1];
    final center = LatLng(lat, lng);

    return BasePage(
      title: "Carte de ${widget.country.name}",
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: _zoom,
                onTap: (_, __) {},
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.voyage',
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_on,
                        color: AppTheme.primaryColor,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      heroTag: "zoom_in",
                      onPressed: () {
                        setState(() {
                          _zoom = _zoom + 1;
                          _mapController.move(center, _zoom);
                        });
                      },
                      child: const Icon(Icons.add),
                    ),
                    FloatingActionButton(
                      heroTag: "zoom_out",
                      onPressed: () {
                        setState(() {
                          _zoom = _zoom - 1;
                          _mapController.move(center, _zoom);
                        });
                      },
                      child: const Icon(Icons.remove),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openInGoogleMaps,
                    icon: const Icon(Icons.map),
                    label: const Text('Ouvrir dans Google Maps'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
