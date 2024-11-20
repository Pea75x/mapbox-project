<template>
  <div v-if="data">
    <div v-for="item in data" :key="item.id">
      <strong>
        {{item.name}}:
      </strong>
      <span @click="item.onclick ? handleClick(item) : null" :class="{ 'ct-clickable': item.onclick }">{{item.value || 'N/A'}}</span>
    </div>
  </div>
</template>

<script>
export default {
  emits: ['click'],
  props: {
    data: {
      type: Array,
      required: true
    }
  },
  methods: {
    handleClick (item) {
      this.$emit('item-clicked', item)
    }
  }
}
</script>
<style>
.ct-clickable {
  cursor: pointer;
  color: blue;
  text-decoration: underline;
}
</style>
