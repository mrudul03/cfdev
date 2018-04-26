package garden

import (
	"code.cloudfoundry.org/garden"
)

func DeployBosh(client garden.Client, dockerRegistries []string) error {
	containerSpec := garden.ContainerSpec{
		Handle:     "deploy-bosh",
		Privileged: true,
		Network:    "10.246.0.0/16",
		Image: garden.ImageRef{
			URI: "/var/vcap/cache/workspace.tar",
		},
		BindMounts: []garden.BindMount{
			{
				SrcPath: "/var/vcap",
				DstPath: "/var/vcap",
				Mode:    garden.BindMountModeRW,
			},
			// TODO macos vs linux and make linux generic to CfdevHome
			// {
			// 	SrcPath: "/var/vcap/cache",
			// 	DstPath: "/var/vcap/cache",
			// 	Mode:    garden.BindMountModeRO,
			// },
			{
				SrcPath: "/home/dgodd/.cfdev/cache",
				DstPath: "/var/vcap/cfdev_cache",
				Mode:    garden.BindMountModeRO,
			},
		},
	}

	container, err := client.Create(containerSpec)
	if err != nil {
		return err
	}

	if err := copyFileToContainer(container, "/home/dgodd/workspace/cfdev/images/cf-oss/allow-mounting", "/usr/bin/allow-mounting"); err != nil {
		return err
	}
	if err := copyFileToContainer(container, "/home/dgodd/workspace/cfdev/images/cf-oss/deploy-bosh", "/usr/bin/deploy-bosh"); err != nil {
		return err
	}
	if err := copyFileToContainer(container, "/home/dgodd/workspace/cfdev/images/cf-oss/bosh-operations/use_gdn_unix_socket.yml", "/var/vcap/use_gdn_unix_socket.yml"); err != nil {
		return err
	}

	if err := runInContainer(container, "allow-mounting", "/usr/bin/allow-mounting"); err != nil {
		return err
	}
	// TODO copy back to workspace.tar // "/usr/bin/deploy-bosh",
	if err := runInContainer(container, "deploy-bosh", "/usr/bin/deploy-bosh"); err != nil {
		return err
	}

	client.Destroy("deploy-bosh")

	return nil
}
