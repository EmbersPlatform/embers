<template>
	<div @click="focusNewTag()" v-bind:class="{'read-only': readOnly}" class="tags-wrapper">
		<span v-for="(tag, index) in tags" class="tag" @click.prevent.stop="remove(index)">
			#{{ tag }}<button v-if="!readOnly" class="close" aria-hidden="true">&times;</button>
		</span>
		<input v-if="!readOnly" :placeholder="placeholder" type="text" v-model="newTag" v-on:keydown.delete.stop="removeLastTag()" v-on:keydown.enter.prevent.stop="addNew(newTag)" class="new-tag"/>
	</div>
</template>
<script>
/*eslint-disable*/
	const validators = {
		email : new RegExp(/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/),
		url : new RegExp(/^(https?|ftp|rmtp|mms):\/\/(([A-Z0-9][A-Z0-9_-]*)(\.[A-Z0-9][A-Z0-9_-]*)+)(:(\d+))?\/?/i),
		text : new RegExp(/^[a-zA-Z]+$/),
		digits : new RegExp(/^[\d() \.\:\-\+#]+$/),
		isodate : new RegExp(/^\d{4}[\/\-](0?[1-9]|1[012])[\/\-](0?[1-9]|[12][0-9]|3[01])$/)
	}
	/*eslint-enable*/
	export default {
		name: 'InputTag',

		props: {
			tags: {
				type: Array,
				default: () => [],
			},
			placeholder: {
				type: String,
				default: '',
			},
			onChange: {
				type: Function,
			},
			readOnly: {
				type: Boolean,
				default: false,
			},
			validate: {
				type: String,
				default: '',
			},
		},
		data() {
			return {
				newTag: '',
			};
		},
		methods: {
			focusNewTag() {
				if (this.readOnly) { return; }
				this.$el.querySelector('.new-tag').focus();
			},
			addNew(tag) {
				if (tag && !this.tags.includes(tag) && this.validateIfNeeded(tag)) {
					this.tags.push(this.format(tag));
					this.tagChange();
				}
				this.newTag = '';
			},
			validateIfNeeded(tagValue) {
				if (this.validate === '' || this.validate === undefined) {
					return true;
				} else if (Object.keys(validators).indexOf(this.validate) > -1) {
					return validators[this.validate].test(tagValue);
				}
				return true;
			},
			remove(index) {
				this.tags.splice(index, 1);
				this.tagChange();
			},
			removeLastTag() {
				if (this.newTag) { return; }
				this.tags.pop();
				this.tagChange();
			},
			tagChange() {
				if (this.onChange) {
					// avoid passing the observer
					this.onChange(JSON.parse(JSON.stringify(this.tags)));
				}
			},
			format(str) {
				str = str.replace(/[^\w\s]/gi, ' ');
				return str.replace(/(?:^\w|[A-Z]|\b\w|\s+)/g, function(match, index) {
					if (+match === 0) return ""; // or if (/\s+/.test(match)) for white spaces
					return match.toUpperCase();
				});
			}
		},
	};
</script>
