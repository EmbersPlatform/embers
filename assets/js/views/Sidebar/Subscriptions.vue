<template>
  <ul id="column">
    <li class="nav_">
      <h2>subscripciones</h2>
    </li>
    <li class="nav_">
      <ul>
        <li class="n_item">
          <router-link class="n_i_wrap" to="/subscriptions/users" exact>
            <span class="n_i_w_clip">
              <i class="fas fa-user"></i>
            </span>
            <span class="n_i_w_content">usuarios</span>
          </router-link>
        </li>
        <li class="n_item">
          <router-link class="n_i_wrap" to="/subscriptions/blocks" exact>
            <span class="n_i_w_clip">
              <i class="fas fa-user-slash"></i>
            </span>
            <span class="n_i_w_content">usuarios bloqueados</span>
          </router-link>
        </li>
        <li class="n_item">
          <router-link class="n_i_wrap" to="/subscriptions/tags" exact>
            <span class="n_i_w_clip">
              <i class="fas fa-tags"></i>
            </span>
            <span class="n_i_w_content">tags</span>
          </router-link>
        </li>
        <li class="n_item">
          <router-link class="n_i_wrap" to="/subscriptions/blocked_tags" exact>
            <span class="n_i_w_clip">
              <i class="fas fa-ban"></i>
            </span>
            <span class="n_i_w_content">tags bloqueados</span>
          </router-link>
        </li>
      </ul>
    </li>
  </ul>
</template>
