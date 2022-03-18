// var.deployable is set in scripts/octo/plan.sh & delpoy.sh
resource "helm_release" "ere_microservice_setup" {
  chart           = "../../helm/${var.deployable}"
  name            = var.helm_chart_name
  namespace       = var.target_namespace
  lint            = true
  cleanup_on_fail = true

  // The following are set in scripts/octo/plan.sh & delpoy.sh:
  set {
    name  = "revision"
    value = var.revision
  }

  set {
    name  = "image.tag"
    value = var.image_tag
  }
  /// End

  set {
    name  = "forceRefresh"
    value = "1.1"
  }

  set {
    name  = "fullnameOverride"
    value = var.helm_chart_name
  }

  set {
    name  = "serviceAccount.name"
    value = var.k8s_serviceaccount
  }

  set {
    name  = "serviceAccount.roleArn"
    value = aws_iam_role.application_policy.arn
  }

  set {
    name  = "global.namespaceName"
    value = var.target_namespace
  }

  set {
    name  = "global.service.name"
    value = var.helm_chart_name
  }

  // Environment vars
  set {
    name  = "envVars.awsRegion"
    value = var.aws_default_region
  }

  set {
    name  = "envVars.SQS.QueueUrl"
    value = aws_sqs_queue.temp_incoming_queue.id
  }

  set {
    name  = "envVars.SNS.OutgoingTopicArn"
    value = aws_sns_topic.temp_outgoing_exceptions_topic.arn
  }

  set {
    name  = "envVars.launchDarkly.Key"
    value = var.launch_darkly_key
  }

  set {
    name  = "envVars.launchDarkly.UserName"
    value = var.launch_darkly_user
  }

  set {
    name  = "envVars.epsagonToken"
    value = var.epsagon_token
  }

  set {
    name  = "envVars.epsagonAppName"
    value = var.epsagon_app_name
  }

  set {
    name  = "envVars.entityApiUserAgent"
    value = var.enity_api_user_agent
  }
  
  set {
    name  = "envVars.entityApiBaseAddress"
    value = var.entity_api_base_address
  }
  
  set {
    name  = "envVars.entityApiDriverPath"
    value = var.entity_api_driver_path
  }
  
  set {
    name  = "envVars.entityApiHometimePath"
    value = var.entity_api_hometime_path
  }
  
  set {
    name  = "envVars.entityApiOrderPath"
    value = var.entity_api_order_path
  }
  
  set {
    name  = "envVars.entityApiTractorPath"
    value = var.entity_api_tractor_path
  }

  set {
    name  = "envVars.simulationsApiBaseAddress"
    value = var.simulations_api_base_address
  }

  set {
    name  = "envVars.requiredDataSources"
    value = var.required_data_sources
  }

  #egress
  # LaunchDarkly I/O
   set {
    name  = "vsd.istio.egress[0].name"
    value = "launchdarkly-apis"
  }

  set {
    name  = "vsd.istio.egress[0].hosts[0]"
    value = "events.launchdarkly.com"
  }

  set {
    name  = "vsd.istio.egress[0].hosts[1]"
    value = "stream.launchdarkly.com"
  }

  set {
    name  = "vsd.istio.egress[0].ports[0].number"
    value = 443
  }

  set {
    name  = "vsd.istio.egress[0].ports[0].protocol"
    value = "HTTPS"
  }
}
