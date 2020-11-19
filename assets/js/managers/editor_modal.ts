let editor_modal;

const get_editor = () => {
  if (editor_modal) return editor_modal;

  editor_modal = document.createElement("post-editor-modal");
  document.body.appendChild(editor_modal);
  return editor_modal;
};

export const request_editor_modal = (default_content = "") => {
  get_editor().showModal(default_content);
};
