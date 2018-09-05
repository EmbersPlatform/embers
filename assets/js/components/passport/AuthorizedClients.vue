<style scoped>
    .action-link {
        cursor: pointer;
    }

    .m-b-none {
        margin-bottom: 0;
    }
</style>

<template>
    <div>
        <div v-if="tokens.length > 0">
            <h5>Aplicaciones autorizadas</h5>
            <!-- Authorized Tokens -->
            <table class="table table-borderless m-b-none">
                <thead>
                    <tr>
                        <th>Nombre</th>
                        <th>Scopes</th>
                        <th></th>
                    </tr>
                </thead>

                <tbody>
                    <tr v-for="token in tokens">
                        <!-- Client Name -->
                        <td style="vertical-align: middle;">
                            {{ token.client.name }}
                        </td>

                        <!-- Scopes -->
                        <td style="vertical-align: middle;">
                            <span v-if="token.scopes.length > 0">
                                {{ token.scopes.join(', ') }}
                            </span>
                        </td>

                        <!-- Revoke Button -->
                        <td style="vertical-align: middle;">
                            <a class="btn btn-sm btn-red" @click="revoke(token)">
                                Revocar
                            </a>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</template>

<script>
import {baseUrl, csrfToken} from '../../config'
    export default {
        /*
         * The component's data.
         */
        data() {
            return {
                tokens: [],
                csrfToken: csrfToken
            };
        },

        /**
         * Prepare the component (Vue 1.x).
         */
        ready() {
            this.prepareComponent();
        },

        /**
         * Prepare the component (Vue 2.x).
         */
        mounted() {
            this.prepareComponent();
        },

        methods: {
            /**
             * Prepare the component (Vue 2.x).
             */
            prepareComponent() {
                this.getTokens();
            },

            /**
             * Get all of the authorized tokens for the user.
             */
            getTokens() {
                this.$http.get('/oauth/tokens')
                        .then(response => {
                            this.tokens = response.data;
                        });
            },

            /**
             * Revoke the given token.
             */
            revoke(token) {
                this.$http.delete('/oauth/tokens/' + token.id)
                        .then(response => {
                            this.getTokens();
                        });
            }
        }
    }
</script>
