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
              <svgicon name="s_account"></svgicon>
            </span>
            <span class="n_i_w_content">usuarios</span>
          </router-link>
        </li>
        <!-- DELAYED
        <li class="n_item">
          <router-link class="n_i_wrap" to="/subscriptions/tags" exact>
            <span class="n_i_w_clip">
              <svgicon name="s_account"></svgicon>
            </span>
            <span class="n_i_w_content">tags</span>
          </router-link>
        </li> -->
        <li class="n_item">
          <router-link class="n_i_wrap" to="/subscriptions/blocks" exact>
            <span class="n_i_w_clip">
              <svgicon name="s_account_block"></svgicon>
            </span>
            <span class="n_i_w_content">bloqueos</span>
          </router-link>
        </li>
      </ul>
    </li>
  </ul>
</template>