<template>
	<div class="switch">
		<input type="checkbox" class="hidden" :id="id" :name="name" :value="value" :class="className" :required="required" :disabled="disabled" @change="onChange" :checked="state">
		<label class="tip" :for="id"></label>
		<label :for="id">
			<slot></slot>
		</label>
	</div>
</template>

<script>
	export default {
		model: {
			prop: 'modelValue',
			event: 'input'
		},
		props: {
			id: {
				type: String,
				default: function () {
					return 'switch-id-' + this._uid;
				},
			},
			name: {
				type: String,
				default: null,
			},
			value: {
				default: null,
			},
			modelValue: {
				default: undefined,
			},
			className: {
				type: String,
				default: null,
			},
			checked: {
				type: Boolean,
				default: false,
			},
			required: {
				type: Boolean,
				default: false,
			},
			disabled: {
				type: Boolean,
				default: false,
			},
			model: {}
		},
		computed: {
			state() {
				if (this.modelValue === undefined) {
					return this.checked;
				}
				if (Array.isArray(this.modelValue)) {
					return this.modelValue.indexOf(this.value) > -1;
				}
				return !!this.modelValue;
			}
		},
		methods: {
			onChange() {
				this.toggle();
			},
			toggle() {
				let value;
				if (Array.isArray(this.modelValue)) {
					value = this.modelValue.slice(0);
					if (this.state) {
						value.splice(value.indexOf(this.value), 1);
					} else {
						value.push(this.value);
					}
				} else {
					value = !this.state;
				}
				this.$emit('input', value);
			}
		},
		watch: {
			checked(newValue) {
				if (newValue !== this.state) {
					this.toggle();
				}
			}
		},
		mounted() {
			if (this.checked && !this.state) {
				this.toggle();
			}
		},
	};
</script>