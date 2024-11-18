<template>
  <div class="ct-map">
    <div ref="map" class="ct-map__container" />
  </div>
</template>

<script>
import Mapbox from 'mapbox-gl'

export default {
  props: {
    configuration: {
      type: Object,
      default: () => ({})
    }
  },

  data () {
    return {
      loaded: false
    }
  },

  head () {
    return {
      link: [
        {
          rel: 'stylesheet',
          href: 'https://api.mapbox.com/mapbox-gl-js/v2.9.2/mapbox-gl.css'
        }
      ]
    }
  },

  mounted () {
    this.map = new Mapbox.Map({
      container: this.$refs.map,
      ...this.configuration
    })

    this.map.on('load', () => {
      this.loaded = true

      this.map.addSource('ArcGIS-dataset', {
        type: 'geojson',
        data: 'https://services3.arcgis.com/fp1tibNcN9mbExhG/arcgis/rest/services/Fiji_Sponges_Algae/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson',
        cluster: true,
        clusterRadius: 50
      })

      this.map.addLayer({
        id: 'arcGIS-clusters',
        type: 'circle',
        source: 'ArcGIS-dataset',
        filter: ['has', 'point_count'],
        paint: {
          'circle-color': [
            'step',
            ['get', 'point_count'],
            '#51bbd6',
            100,
            '#f1f075',
            750,
            '#f28cb1'
          ],
          'circle-radius': [
            'step',
            ['get', 'point_count'],
            20,
            100,
            30,
            750,
            40
          ]
        }
      })

      this.map.addLayer({
        id: 'cluster-count',
        type: 'symbol',
        source: 'ArcGIS-dataset',
        filter: ['has', 'point_count'],
        layout: {
          'text-field': ['get', 'point_count_abbreviated'],
          'text-font': ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
          'text-size': 12
        }
      })

      this.map.addLayer({
        id: 'arcGIS-point',
        type: 'circle',
        source: 'ArcGIS-dataset',
        filter: ['!', ['has', 'point_count']],
        paint: {
          'circle-color': '#4264fb',
          'circle-radius': 8,
          'circle-stroke-width': 2,
          'circle-stroke-color': '#ffffff'
        }
      })
    })

    this.map.on('click', 'arcGIS-clusters', (e) => {
      const features = this.map.queryRenderedFeatures(e.point, {
        layers: ['arcGIS-clusters']
      })
      const clusterId = features[0].properties.cluster_id
      this.map
        .getSource('ArcGIS-dataset')
        .getClusterExpansionZoom(clusterId, (err, zoom) => {
          if (err) {
            return
          }
          this.map.easeTo({
            center: features[0].geometry.coordinates,
            zoom
          })
        })
    })

    this.map.on('click', 'arcGIS-point', (e) => {
      const coordinates = e.features[0].geometry.coordinates.slice()

      while (Math.abs(e.lngLat.lng - coordinates[0]) > 180) {
        coordinates[0] += e.lngLat.lng > coordinates[0] ? 360 : -360
      }

      const data = e.features[0].properties

      const popupContent = `
        <div class="popup-content">
          <strong>Species Name:</strong> ${data.scientificName || 'N/A'}<br />
          <strong>Genus:</strong> ${data.genus || 'N/A'}<br />
          <strong>Family:</strong> ${data.family || 'N/A'}<br />
          <strong>Location:</strong> ${data.locality || 'N/A'}<br />
          <strong>Scientific Name Authorship:</strong> ${data.scientificNameAuthorship || 'N/A'}<br />
        </div>
      `
      new Mapbox.Popup({ offset: 25 }).setHTML(popupContent).setLngLat(e.features[0].geometry.coordinates).addTo(this.map)
    })
  }
}
</script>

<style lang="postcss" scoped>
.ct-map {
  height: 512px;

  &__container {
    @apply h-full;
  }
}
</style>
