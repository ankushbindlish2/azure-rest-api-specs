import "./Neon.Postgres.Models/projects.tsp";
import "./Neon.Postgres.Models/branches.tsp";
import "./Neon.Postgres.Models/commons.tsp";
import "./Neon.Postgres.Models/compute.tsp";
import "./Neon.Postgres.Models/databases.tsp";
import "./Neon.Postgres.Models/connection.tsp";
import "./Neon.Postgres.Models/roles.tsp";
import "./Neon.Postgres.Models/endpoints.tsp";
import "./LiftrBase.Data/main.tsp";

import "@azure-tools/typespec-autorest";
import "@azure-tools/typespec-azure-core";
import "@azure-tools/typespec-azure-resource-manager";

using TypeSpec.Http;
using TypeSpec.Rest;
using Azure.ResourceManager;
using TypeSpec.Versioning;
using LiftrBase.Data;

@armProviderNamespace
@service(#{ title: "Neon.Postgres" })
@versioned(Neon.Postgres.Versions)
@armCommonTypesVersion("v5")
namespace Neon.Postgres;

@doc("Supported API versions for the Neon.Postgres resource provider.")
enum Versions {
  @doc("Dependent on Azure.ResourceManager.Versions.v1_0_Preview_1, LiftrBase.Versions.v1_preview, LiftrBase.Data.Versions.v1_preview")
  @useDependency(Azure.ResourceManager.Versions.v1_0_Preview_1)
  @useDependency(LiftrBase.Versions.v1_preview)
  @useDependency(LiftrBase.Data.Versions.v1_preview)
  v1_preview: "2024-12-22-preview",

  @doc("Dependent on Azure.ResourceManager.Versions.v1_0_Preview_1, LiftrBase.Versions.v1_preview, LiftrBase.Data.Versions.v1_preview")
  @useDependency(Azure.ResourceManager.Versions.v1_0_Preview_1)
  @useDependency(LiftrBase.Versions.v1_preview)
  @useDependency(LiftrBase.Data.Versions.v2_preview)
  v2_preview: "2025-03-01-preview",

  @doc("Dependent on Azure.ResourceManager.Versions.v1_0_Preview_1, LiftrBase.Versions.v1_preview, LiftrBase.Data.Versions.v1_preview")
  @useDependency(Azure.ResourceManager.Versions.v1_0_Preview_1)
  @useDependency(LiftrBase.Versions.v1_preview)
  @useDependency(LiftrBase.Data.Versions.v2_preview)
  v2025_03_01: "2025-03-01",
}

interface Operations extends Azure.ResourceManager.Operations {}

@doc("Organization Resource by Neon")
model OrganizationResource is TrackedResource<OrganizationProperties> {
  @key("organizationName")
  @pattern("^[a-zA-Z0-9][a-zA-Z0-9_\\-.: ]*$")
  @segment("organizations")
  @minLength(1)
  @maxLength(50)
  @doc("Name of the Neon Organizations resource")
  @path
  name: string;
}

@armResourceOperations
interface Organizations {
  get is ArmResourceRead<OrganizationResource>;
  createOrUpdate is ArmResourceCreateOrUpdateAsync<OrganizationResource>;
  update is ArmResourcePatchAsync<OrganizationResource, OrganizationProperties>;
  delete is ArmResourceDeleteWithoutOkAsync<OrganizationResource>;
  listByResourceGroup is ArmResourceListByParent<OrganizationResource>;
  listBySubscription is ArmListBySubscription<OrganizationResource>;

  @doc("Action to retrieve the PostgreSQL versions.")
  @added(Neon.Postgres.Versions.v2_preview)
  @autoRoute
  @armResourceAction(OrganizationResource)
  @post
  getPostgresVersions(
    ...ResourceInstanceParameters<Models.PgVersion>,

    @doc("Post Action to retrieve the PostgreSQL versions.")
    @body
    parameters?: Models.PgVersion,
  ): ArmResponse<Models.PgVersionsResult> | ErrorResponse;
}

@armResourceOperations
@added(Neon.Postgres.Versions.v2_preview)
interface Projects {
  get is ArmResourceRead<Project>;
  createOrUpdate is ArmResourceCreateOrReplaceAsync<Project>;
  update is ArmResourcePatchAsync<Project, Models.ProjectProperties>;
  delete is ArmResourceDeleteSync<Project>;
  list is ArmResourceListByParent<Project>;

  @doc("Action to retrieve the connection URI for the Neon Database.")
  @autoRoute
  @armResourceAction(Models.ConnectionUriProperties)
  @post
  getConnectionUri(
    ...ResourceInstanceParameters<Project>,

    @doc("Additional parameters for retrieving the database connection URI.")
    @body
    connectionUriParameters: Models.ConnectionUriProperties,
  ): ArmResponse<Models.ConnectionUriProperties> | ErrorResponse;
}

@doc("The Project resource type.")
@added(Neon.Postgres.Versions.v2_preview)
@parentResource(OrganizationResource)
model Project is ProxyResource<Models.ProjectProperties> {
  ...ResourceNameParameter<Project>;
}

@armResourceOperations
@added(Neon.Postgres.Versions.v2_preview)
interface Branches {
  get is ArmResourceRead<Branch>;
  createOrUpdate is ArmResourceCreateOrReplaceAsync<Branch>;
  update is ArmResourcePatchAsync<Branch, Models.BranchProperties>;
  delete is ArmResourceDeleteSync<Branch>;
  list is ArmResourceListByParent<Branch>;
}

@doc("The Branch resource type.")
@added(Neon.Postgres.Versions.v2_preview)
@parentResource(Project)
model Branch is ProxyResource<Models.BranchProperties> {
  ...ResourceNameParameter<Branch>;
}

@armResourceOperations
@added(Neon.Postgres.Versions.v2_preview)
interface Computes {
  get is ArmResourceRead<Compute>;
  createOrUpdate is ArmResourceCreateOrReplaceAsync<Compute>;
  update is ArmResourcePatchAsync<Compute, Models.ComputeProperties>;
  delete is ArmResourceDeleteSync<Compute>;
  list is ArmResourceListByParent<Compute>;
}

@doc("The Compute resource type.")
@added(Neon.Postgres.Versions.v2_preview)
@parentResource(Branch)
model Compute is ProxyResource<Models.ComputeProperties> {
  ...ResourceNameParameter<Compute>;
}

@armResourceOperations
@added(Neon.Postgres.Versions.v2_preview)
interface NeonDatabases {
  get is ArmResourceRead<NeonDatabase>;
  createOrUpdate is ArmResourceCreateOrReplaceAsync<NeonDatabase>;
  update is ArmResourcePatchAsync<NeonDatabase, Models.NeonDatabaseProperties>;
  delete is ArmResourceDeleteSync<NeonDatabase>;
  list is ArmResourceListByParent<NeonDatabase>;
}

@doc("The Neon Database resource type.")
@added(Neon.Postgres.Versions.v2_preview)
@parentResource(Branch)
model NeonDatabase is ProxyResource<Models.NeonDatabaseProperties> {
  ...ResourceNameParameter<NeonDatabase>;
}

@armResourceOperations
@added(Neon.Postgres.Versions.v2_preview)
interface NeonRoles {
  get is ArmResourceRead<NeonRole>;
  createOrUpdate is ArmResourceCreateOrReplaceAsync<NeonRole>;
  update is ArmResourcePatchAsync<NeonRole, Models.NeonRoleProperties>;
  delete is ArmResourceDeleteSync<NeonRole>;
  list is ArmResourceListByParent<NeonRole>;
}

@doc("The Neon Role resource type.")
@added(Neon.Postgres.Versions.v2_preview)
@parentResource(Branch)
model NeonRole is ProxyResource<Models.NeonRoleProperties> {
  ...ResourceNameParameter<NeonRole>;
}

@armResourceOperations
@added(Neon.Postgres.Versions.v2_preview)
interface Endpoints {
  get is ArmResourceRead<Endpoint>;
  createOrUpdate is ArmResourceCreateOrReplaceAsync<Endpoint>;
  update is ArmResourcePatchAsync<Endpoint, Models.EndpointProperties>;
  delete is ArmResourceDeleteSync<Endpoint>;
  list is ArmResourceListByParent<Endpoint>;
}

@doc("The Neon compute endpoint resource type.")
@added(Neon.Postgres.Versions.v2_preview)
@parentResource(Branch)
model Endpoint is ProxyResource<Models.EndpointProperties> {
  ...ResourceNameParameter<Endpoint>;
}
