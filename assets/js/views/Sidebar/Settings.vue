<template>
	<ul id="column">
		<li class="nav_">
			<h2>configuracion</h2>
		</li>
		<li class="nav_">
			<ul>
				<li class="n_item">
					<router-link class="n_i_wrap" to="/settings" exact>
						<span class="n_i_w_clip">
							<svgicon name="s_account"></svgicon>
						</span>
						<span class="n_i_w_content">mi cuenta</span>
					</router-link>
				</li>
				<li class="n_item">
					<router-link class="n_i_wrap" to="/settings/appearance">
						<span class="n_i_w_clip">
							<svgicon name="s_appearance"></svgicon>
						</span>
						<span class="n_i_w_content">apariencia</span>
					</router-link>
				</li>
				<li class="n_item">
					<router-link class="n_i_wrap" to="/settings/content">
						<span class="n_i_w_clip">
							<svgicon name="s_content"></svgicon>
						</span>
						<span class="n_i_w_content">contenido</span>
					</router-link>
				</li>
				<li class="n_item">
					<router-link class="n_i_wrap" to="/settings/privacy">
						<span class="n_i_w_clip">
							<svgicon name="s_privacy"></svgicon>
						</span>
						<span class="n_i_w_content">privacidad</span>
					</router-link>
				</li>
				<li class="n_item">
					<router-link class="n_i_wrap" to="/settings/security">
						<span class="n_i_w_clip">
							<svgicon name="s_security"></svgicon>
						</span>
						<span class="n_i_w_content">seguridad</span>
					</router-link>
				</li>
				<!-- <li class="n_item">
					<router-link class="n_i_wrap" to="/settings/apps">
						<span class="n_i_w_clip">
							<svgicon name="s_account"></svgicon>
						</span>
						<span class="n_i_w_content">aplicaciones</span>
					</router-link>
				</li> -->
			</ul>
		</li>
	</ul>
</template>