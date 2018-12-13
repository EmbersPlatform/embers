<template>
	<!-- <div class="comments" :class="{'renderbox' : loading}" :data-renderbox-message="[(!lastPage && !loading) ? 'moaring' : 'Cargando...']"> -->
	<div v-if="comments.length > 0 || bottomComments.length > 0" class="comments-list" :class="{'renderbox' : loading}" data-renderbox-message="Cargando comentarios...">
		<Comment v-for="comment in comments" :key="comment.id" :comment="comment" :postId="postId" @deleted="deleteComment"></Comment>

		<button v-if="!lastPage && !loading" @click.prevent="loadMore" class="button" data-button-size="medium" data-button-font="medium" data-button-normal-text data-button-unmask>
			Cargar más comentarios
		</button>
		<!-- display additional comments which do not correspond to the next one in the list (e.g. newly created comments
		when the comment list hasn't been fully loaded -->
		<Comment v-for="comment in bottomComments" :key="comment.id" :comment="comment" :postId="postId" @deleted="deleteComment"></Comment>
	</div>
</template>

<script>
	import Comment from './Comment';

	export default {
		props: ['postId', 'comments', 'bottomComments', 'lastPage', 'loading'],
		components: { Comment },

		methods: {
			/**
			 * Deletes a specified comment from the list
			 * @param comment Comment object
			 */
			deleteComment(comment) {
				this.comments.splice(this.comments.indexOf(comment), 1);
			},

			/**
			 * Triggered when the "Load more" link gets clicked
			 */
			loadMore() {
				this.$emit('loadMore');
			}
		},
	}
</script>