
(function($) {
  $(function(){
    var document_workflow_step = $('[data-document-slug]').attr('data-document-slug');
    var document_step_type = $('[data-document-step-type]').attr('data-document-step-type');
    if(document_step_type !== "default_step"){
      $(".workflow_step").fadeTo(500,1)
    }
    if (document_step_type === "end_step") {
      $(".workflow_step").show()
      $(".content").find(":input").prop('disabled', true);
      $(".content").find(".editableHtml").removeClass("editableHtml");
    } else if(document_workflow_step !== ""){
      $(".workflow_step:not(#"+document_workflow_step+")").hide()
      $("#"+document_workflow_step).show()
    } else {
      $(".workflow_step").hide()
    }

  })
  $(window).load(function(){
    var document_step_type = $('[data-document-step-type]').attr('data-document-step-type');

    if(document_step_type !== "end_step" && document_step_type !== ""){
      $(".workflow_step.staff").show().fadeTo(500,0.5)
      $(".workflow_step.staff").find(":input").prop('disabled', true);
    }
  });
})(jQuery);
