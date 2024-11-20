<template>
  <div class="ct-map">
    <div ref="map" class="ct-map__container" />
    <Modal
      :show="showModal"
      @change="toggleModal">
      <template #header>
        <h3>{{ searchTitle || 'Loading...' }}</h3>
      </template>
      <div v-if="searchData" class="ct-data-text">
        <ul v-for="(item) in searchData" :key="item.id">
          <li>{{ item[searchName] }}</li>
        </ul>
      </div>
    </Modal>
  </div>
</template>

<script>
import Vue from 'vue'
import Mapbox from 'mapbox-gl'
import Modal from '@/components/Base/Modal.vue'
import Popup from '@//components/Base/Popup.vue'

export default {
  components: {
    Modal
  },

  props: {
    configuration: {
      type: Object,
      default: () => ({})
    }
  },

  data () {
    return {
      loaded: false,
      searchName: '',
      searchTitle: '',
      searchData: [],
      message: 'Species in this location',
      showModal: false
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

  methods: {
    async fetchData (searchItem, searchData) {
      try {
        const response = await fetch(`http://localhost:3000/v1/species_locations/search_${searchItem}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json'
          },
          body: JSON.stringify({
            [searchItem]: searchData
          })
        })

        const data = await response.json()
        return data
      } catch (error) {
        console.error('Error fetching species or locations:', error)
      }
    },
    toggleModal () {
      this.showModal = !this.showModal
    },
    async clickPopupLink (searchItem, searchTitle, searchData) {
      try {
        const data = await this.fetchData(searchItem, searchData)
        this.searchData = data
        this.searchTitle = searchTitle
        this.searchName = searchItem === 'locality' ? 'scientific_name' : 'locality'
        this.showModal = true
      } catch (error) {
        console.error(error)
      }
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
      if (e.features && e.features.length > 0) {
        const coordinates = e.features[0].geometry.coordinates.slice()

        while (Math.abs(e.lngLat.lng - coordinates[0]) > 180) {
          coordinates[0] += e.lngLat.lng > coordinates[0] ? 360 : -360
        }

        const features = e.features[0]
        const data = e.features[0].properties

        const PopupDiv = Vue.extend(Popup)
        new Mapbox.Popup({ offset: 25 }).setHTML('<div id="popup-content"></div>').setLngLat(features.geometry.coordinates).addTo(this.map)

        const popupInstance = new PopupDiv({
          propsData: {
            data: [
              { name: 'Species Name', value: data.scientificName, onclick: () => { this.clickPopupLink('scientific_name', 'Native to:', data.scientificName) } },
              { name: 'Genus', value: data.genus },
              { name: 'Family', value: data.family },
              { name: 'Locality', value: data.locality, onclick: () => { this.clickPopupLink('locality', 'Local species:', data.locality) } }
            ]
          }
        })
        popupInstance.$mount('#popup-content')

        popupInstance.$on('item-clicked', (item) => { item.onclick && item.onclick() })
      } else {
        console.error('NO')
      }
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

.ct-data-text {
  font-size: 12px;
}
</style>
