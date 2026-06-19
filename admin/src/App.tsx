import { Layout, Menu, Space, Tag, Typography } from 'antd'
import {
  DashboardOutlined,
  MessageOutlined,
  SettingOutlined,
  TeamOutlined,
} from '@ant-design/icons'

const { Header, Sider, Content } = Layout

export default function App() {
  return (
    <Layout className="shell">
      <Sider breakpoint="lg" collapsedWidth="0" theme="dark">
        <div className="brand">ZEROON</div>
        <Menu
          theme="dark"
          mode="inline"
          defaultSelectedKeys={['overview']}
          items={[
            { key: 'overview', icon: <DashboardOutlined />, label: '概览' },
            { key: 'users', icon: <TeamOutlined />, label: '用户' },
            { key: 'prompts', icon: <MessageOutlined />, label: 'Prompt' },
            { key: 'settings', icon: <SettingOutlined />, label: '系统配置' },
          ]}
        />
      </Sider>
      <Layout>
        <Header className="header">
          <Space>
            <Typography.Text strong>ZEROON 管理后台</Typography.Text>
            <Tag color="gold">Sprint 0</Tag>
          </Space>
        </Header>
        <Content className="content">
          <section className="panel">
            <Typography.Title level={2}>研发基线已建立</Typography.Title>
            <Typography.Paragraph>
              当前后台仅提供工程入口。用户、Prompt 和系统配置将在对应 API
              通过鉴权与审计验收后接入。
            </Typography.Paragraph>
          </section>
        </Content>
      </Layout>
    </Layout>
  )
}

