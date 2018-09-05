<template>
	<ul id="column">
		<li class="nav_">
			<h2>descubre</h2>
			<ul>
				<li class="n_item">
					<router-link class="n_i_wrap" to="/discover" exact>
						<span class="n_i_w_clip">
							<svgicon name="s_global"></svgicon>
						</span>
						<span class="n_i_w_content">global</span>
					</router-link>
				</li>
			</ul>
		</li>
		<li class="nav_ sub_">
			<h3>filtrar por:</h3>
			<ul>
				<li class="n_item">
					<router-link class="n_i_wrap" to="/discover#recent" exact>
						<span class="n_i_w_clip">
							<svgicon name="s_recent"></svgicon>
						</span>
						<span class="n_i_w_content">reciente</span>
					</router-link>
				</li>
				<li class="n_item">
					<router-link class="n_i_wrap" to="/discover#text" exact>
						<span class="n_i_w_clip">
							<svgicon name="s_text_lines"></svgicon>
						</span>
						<span class="n_i_w_content">texto</span>
					</router-link>
				</li>
				<li class="n_item">
					<router-link class="n_i_wrap" to="/discover#image" exact>
						<span class="n_i_w_clip">
							<svgicon name="s_image"></svgicon>
						</span>
						<span class="n_i_w_content">imágenes</span>
					</router-link>
				</li>
				<li class="n_item">
					<router-link class="n_i_wrap" to="/discover#video" exact>
						<span class="n_i_w_clip">
							<svgicon name="s_video"></svgicon>
						</span>
						<span class="n_i_w_content">videos</span>
					</router-link>
				</li>
				<li class="n_item">
					<router-link class="n_i_wrap" to="/discover#audio" exact>
						<span class="n_i_w_clip">
							<svgicon name="s_audio"></svgicon>
						</span>
						<span class="n_i_w_content">audios</span>
					</router-link>
				</li>
				<li class="n_item">
					<router-link class="n_i_wrap" to="/discover#link" exact>
						<span class="n_i_w_clip">
							<svgicon name="s_link"></svgicon>
						</span>
						<span class="n_i_w_content">enlaces</span>
					</router-link>
				</li>
			</ul>
		</li>
		<!-- <li class="nav_">
			<h3>personas</h3>
		</li> -->
	</ul>
</template>